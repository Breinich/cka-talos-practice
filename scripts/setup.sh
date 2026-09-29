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
need kubectl; need sed; need grep; validate_scope; context_guard "$YES"
kubectl cluster-info >/dev/null
mkdir -p "$STATE_DIR"; chmod 700 "$STATE_DIR"; umask 077
if [[ -f "$STATE_DIR/state.env" ]]; then
  saved_identity="$(bash -c 'source "$1"; printf "%s|%s|%s" "$NAMESPACE" "$CONTEXT" "$SERVER"' _ "$STATE_DIR/state.env")"
  current_identity="$NAMESPACE|$(kubectl config current-context)|$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"
  [[ "$saved_identity" == "$current_identity" ]] || die "saved state belongs to $saved_identity, not $current_identity; restore/teardown it or use a separate CKA_LAB_STATE_DIR"
fi

if kubectl get ns "$NAMESPACE" >/dev/null 2>&1 && ! ns_owned; then
  die "namespace $NAMESPACE already exists without the lab ownership label"
fi

# Preserve the state before the first setup. Reruns never overwrite that baseline.
if [[ ! -f "$STATE_DIR/state.env" ]]; then
  existed=false
  if kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
    existed=true
    umask 077
    kubectl get all,configmap,secret,serviceaccount,role.rbac.authorization.k8s.io,rolebinding.rbac.authorization.k8s.io,pvc,networkpolicy -n "$NAMESPACE" -o yaml >"$STATE_DIR/before.yaml"
  else
    printf 'apiVersion: v1\nkind: List\nitems: []\n' >"$STATE_DIR/before.yaml"
  fi
  {
    printf 'CONTEXT=%q\nSERVER=%q\n' "$(kubectl config current-context)" "$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"
    printf 'PREFIX=%q\nNAMESPACE=%q\nNAMESPACE_EXISTED=%q\n' "$PREFIX" "$NAMESPACE" "$existed"
    printf 'CREATED_AT=%q\n' "$(date -u +%FT%TZ)"
  } >"$STATE_DIR/state.env"
  chmod 600 "$STATE_DIR/state.env" "$STATE_DIR/before.yaml"
fi

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml |
    kubectl label --local -f - cka-lab.io/owner=cka-talos-practice cka-lab.io/prefix="$PREFIX" --overwrite -o yaml |
    kubectl apply -f - >/dev/null
fi
render_fixture "$ROOT/fixtures/base/lab.yaml" | kubectl apply -f - >/dev/null
render_fixture "$ROOT/fixtures/troubleshooting/broken.yaml" | kubectl apply -f - >/dev/null

metrics=false; networkpolicy=false; ingress=false; gateway=false; storageclass=false; expandable=false; helm=false; talosctl=false
kubectl get --raw /apis/metrics.k8s.io/v1beta1 >/dev/null 2>&1 && metrics=true || :
# API presence alone does not prove enforcement. Recognized CNI pods provide a conservative hint.
if kubectl api-resources --api-group=networking.k8s.io -o name | grep -qx networkpolicies; then
  if kubectl get pods -A -o name 2>/dev/null | grep -Eiq '(cilium|calico|weave|antrea)'; then networkpolicy=true; fi
fi
kubectl get ingressclass >/dev/null 2>&1 && [[ -n "$(kubectl get ingressclass -o name 2>/dev/null)" ]] && ingress=true || :
if has_api gateway.networking.k8s.io && [[ -n "$(kubectl get gatewayclass -o name 2>/dev/null)" ]] && [[ -n "$(kubectl get gateway -A -o name 2>/dev/null)" ]]; then gateway=true; fi
default_sc="$(kubectl get storageclass -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}' 2>/dev/null || true)"
[[ -n "$default_sc" ]] && storageclass=true || :
[[ -n "$default_sc" && "$(kubectl get storageclass "$default_sc" -o jsonpath='{.allowVolumeExpansion}' 2>/dev/null)" == true ]] && expandable=true || :
command -v helm >/dev/null 2>&1 && helm=true || :
command -v talosctl >/dev/null 2>&1 && talosctl=true || :
{
  printf 'METRICS=%s\nNETWORKPOLICY=%s\nINGRESS=%s\nGATEWAY=%s\nSTORAGECLASS=%s\nEXPANDABLE=%s\nHELM=%s\nTALOSCTL=%s\n' \
    "$metrics" "$networkpolicy" "$ingress" "$gateway" "$storageclass" "$expandable" "$helm" "$talosctl"
} >"$STATE_DIR/capabilities.env"

log "Lab ready in namespace $NAMESPACE. Capabilities:"
cat "$STATE_DIR/capabilities.env" >&2
log "Start with: less TASKS.md"
