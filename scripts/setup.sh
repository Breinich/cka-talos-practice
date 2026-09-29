#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/common.sh"

YES=false
while (($#)); do
  case "$1" in
    --yes) YES=true ;;
    --prefix) shift; PREFIX="${1:?missing prefix}"; NAMESPACE="$PREFIX" ;;
    --namespace) shift; NAMESPACE="${1:?missing namespace}" ;;
    -h|--help) echo "usage: $0 [--yes] [--prefix NAME] [--namespace NAME]"; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
  shift
done
need kubectl; need sed; need grep; need python3; validate_scope; context_guard "$YES"
kubectl cluster-info >/dev/null
mkdir -p "$STATE_DIR"; chmod 700 "$STATE_DIR"; umask 077
if [[ -f "$STATE_DIR/state.env" ]]; then
  [[ -r "$STATE_DIR/before.yaml" ]] || die "saved state lacks baseline manifest; refusing setup"
  saved_identity="$(bash -c 'source "$1"; printf "%s|%s|%s" "$NAMESPACE" "$CONTEXT" "$SERVER"' _ "$STATE_DIR/state.env")"
  current_identity="$NAMESPACE|$(kubectl config current-context)|$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"
  [[ "$saved_identity" == "$current_identity" ]] || die "saved state belongs to $saved_identity, not $current_identity; restore/teardown it or use a separate CKA_LAB_STATE_DIR"
fi

if kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
  ns_owned || die "namespace $NAMESPACE already exists without the lab ownership label"
  refuse_storage_cleanup
  # Do not silently adopt or overwrite an unrelated object with a fixture name.
  for fixture in configmap/lab-info deployment.apps/web service/web pod/toolbox \
                 serviceaccount/relay-identity role.rbac.authorization.k8s.io/relay-reader \
                 rolebinding.rbac.authorization.k8s.io/relay-reader \
                 deployment.apps/broken-image deployment.apps/broken-ready pod/unschedulable service/broken-service \
                 deployment.apps/ember-api deployment.apps/ember-release deployment.apps/ember-recovery \
                 service/ember-ledger statefulset.apps/ember-ledger deployment.apps/ember-placement \
                 deployment.apps/ember-autoscale deployment.apps/estuary-api service/estuary-front \
                 service/estuary-catalog service/estuary-port; do
    if kubectl get "$fixture" -n "$NAMESPACE" >/dev/null 2>&1; then
      owner="$(kubectl get "$fixture" -n "$NAMESPACE" -o jsonpath='{.metadata.labels.cka-lab\.io/owner}')"
      [[ "$owner" == cka-talos-practice ]] || die "fixture collision with unowned $fixture in $NAMESPACE"
    fi
  done
fi

# Commit the baseline only after every snapshot call succeeds. Reruns retain it.
if [[ ! -f "$STATE_DIR/state.env" ]]; then
  existed=false
  tmp="$(mktemp -d "$STATE_DIR/snapshot.XXXXXXXX")"
  trap 'rm -rf "$tmp"' EXIT
  if kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
    existed=true
    kubectl get "$LAB_NAMESPACED_KINDS" -n "$NAMESPACE" -o json >"$tmp/core.json"
    files=("$tmp/core.json")
    if has_httproutes; then
      kubectl get httproute.gateway.networking.k8s.io -n "$NAMESPACE" -o json >"$tmp/route.json"
      files+=("$tmp/route.json")
    fi
    python3 "$ROOT/scripts/snapshot.py" "${files[@]}" >"$tmp/before.yaml"
  else
    printf '{"apiVersion":"v1","kind":"List","items":[]}\n' >"$tmp/before.yaml"
  fi
  {
    printf 'CONTEXT=%q\nSERVER=%q\n' "$(kubectl config current-context)" "$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"
    printf 'PREFIX=%q\nNAMESPACE=%q\nNAMESPACE_EXISTED=%q\n' "$PREFIX" "$NAMESPACE" "$existed"
    printf 'CREATED_AT=%q\n' "$(date -u +%FT%TZ)"
  } >"$tmp/state.env"
  chmod 600 "$tmp/state.env" "$tmp/before.yaml"
  mv "$tmp/before.yaml" "$STATE_DIR/before.yaml"
  mv "$tmp/state.env" "$STATE_DIR/state.env"
fi

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml |
    kubectl label --local -f - cka-lab.io/owner=cka-talos-practice cka-lab.io/prefix="$PREFIX" --overwrite -o yaml |
    kubectl apply -f - >/dev/null
fi
render_fixture "$ROOT/fixtures/base/lab.yaml" | kubectl apply -f - >/dev/null
render_fixture "$ROOT/fixtures/troubleshooting/broken.yaml" | kubectl apply -f - >/dev/null
render_fixture "$ROOT/fixtures/base/workloads.yaml" | kubectl apply -f - >/dev/null
render_fixture "$ROOT/fixtures/base/networking.yaml" | kubectl apply -f - >/dev/null
# Establish a real previous ReplicaSet before introducing the failed revision.
kubectl rollout status deployment/ember-recovery -n "$NAMESPACE" --timeout=90s >/dev/null || die "ember-recovery baseline not ready; no bad revision seeded"
kubectl set image deployment/ember-recovery api=nginx:no-such-tag-cka-practice -n "$NAMESPACE" >/dev/null

metrics=false; networkpolicy=false; ingress=false; gateway=false; storageclass=false; expandable=false; helm=false; talosctl=false
kubectl get --raw /apis/metrics.k8s.io/v1beta1 >/dev/null 2>&1 && kubectl top nodes >/dev/null 2>&1 && metrics=true || :
# API presence alone does not prove enforcement. Recognized CNI pods provide a conservative hint.
if kubectl api-resources --api-group=networking.k8s.io -o name | grep -qx networkpolicies; then
  if kubectl get pods -A -o name 2>/dev/null | grep -Eiq '(cilium|calico|weave|antrea)'; then networkpolicy=true; fi
fi
kubectl get ingressclass >/dev/null 2>&1 && [[ -n "$(kubectl get ingressclass -o name 2>/dev/null)" ]] && ingress=true || :
# Only an accepted/programmed HTTP listener allowing same-namespace routes counts.
if has_httproutes; then
  while read -r gw; do
    [[ -n "$gw" ]] || continue
    if kubectl get "$gw" -n "$NAMESPACE" -o json | python3 "$ROOT/scripts/check_resource.py" gateway; then
      gateway=true; break
    fi
  done < <(kubectl get gateway.gateway.networking.k8s.io -n "$NAMESPACE" -o name 2>/dev/null || true)
fi
default_sc="$(kubectl get storageclass -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}' 2>/dev/null || true)"
[[ -n "$default_sc" ]] && storageclass=true || :
[[ -n "$default_sc" && "$(kubectl get storageclass "$default_sc" -o jsonpath='{.allowVolumeExpansion}' 2>/dev/null)" == true ]] && expandable=true || :
command -v helm >/dev/null 2>&1 && helm=true || :
command -v talosctl >/dev/null 2>&1 && talosctl get members -o json >/dev/null 2>&1 && talosctl=true || :
{
  printf 'METRICS=%s\nNETWORKPOLICY=%s\nINGRESS=%s\nGATEWAY=%s\nSTORAGECLASS=%s\nEXPANDABLE=%s\nHELM=%s\nTALOSCTL=%s\n' \
    "$metrics" "$networkpolicy" "$ingress" "$gateway" "$storageclass" "$expandable" "$helm" "$talosctl"
} >"$STATE_DIR/capabilities.env"

log "Lab ready in namespace $NAMESPACE. Capabilities:"
cat "$STATE_DIR/capabilities.env" >&2
log "Start with: less TASKS.md"
