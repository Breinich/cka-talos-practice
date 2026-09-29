#!/usr/bin/env bash
# Shared helpers; bash is required by the lab scripts.
set -o errexit -o nounset -o pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${CKA_LAB_PREFIX:-cka-practice}"
NAMESPACE="${CKA_LAB_NAMESPACE:-$PREFIX}"
OWNER_LABEL="cka-lab.io/owner=cka-talos-practice"
# Every namespaced kind a live task or setup may intentionally create/change.
LAB_NAMESPACED_KINDS="pod,service,configmap,secret,serviceaccount,replicationcontroller,daemonset.apps,deployment.apps,replicaset.apps,statefulset.apps,job.batch,cronjob.batch,horizontalpodautoscaler.autoscaling,ingress.networking.k8s.io,networkpolicy.networking.k8s.io,poddisruptionbudget.policy,role.rbac.authorization.k8s.io,rolebinding.rbac.authorization.k8s.io"
STATE_DIR="${CKA_LAB_STATE_DIR:-$ROOT/.lab}"

log() { printf '%s\n' "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"; }

validate_scope() {
  case "$PREFIX" in ''|*[!a-z0-9-]*|-*|*-) die "unsafe prefix: $PREFIX";; esac
  case "$NAMESPACE" in ''|*[!a-z0-9-]*|-*|*-) die "unsafe namespace: $NAMESPACE";; esac
  [[ ${#PREFIX} -ge 3 && ${#NAMESPACE} -ge 3 ]] || die "prefix and namespace must be at least 3 characters"
  [[ "$NAMESPACE" == "$PREFIX" || "$NAMESPACE" == "$PREFIX"-* ]] || die "namespace must equal or begin with prefix"
}

context_guard() {
  local confirmed="${1:-false}" context server
  context="$(kubectl config current-context 2>/dev/null || true)"
  [[ -n "$context" ]] || die "kubectl has no current context"
  server="$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null || true)"
  log "Context: $context ($server)"
  if [[ "$context" =~ (prod|production|shared|customer) ]] && [[ "$confirmed" != true ]]; then
    die "context '$context' looks unsafe; inspect it, then rerun with --yes"
  fi
  if [[ "$context" != "admin@lake" && "$confirmed" != true ]]; then
    die "expected admin@lake; rerun with --yes only after verifying the target"
  fi
}

has_api() { kubectl api-resources --api-group="$1" -o name 2>/dev/null | grep -q .; }
ns_owned() {
  [[ "$(kubectl get ns "$NAMESPACE" -o jsonpath='{.metadata.labels.cka-lab\.io/owner}' 2>/dev/null || true)" == "cka-talos-practice" ]] &&
    [[ "$(kubectl get ns "$NAMESPACE" -o jsonpath='{.metadata.labels.cka-lab\.io/prefix}' 2>/dev/null || true)" == "$PREFIX" ]]
}
render_fixture() { sed "s/__NAMESPACE__/$NAMESPACE/g; s/__PREFIX__/$PREFIX/g" "$1"; }

# Never implicitly delete persistent data, including cluster-scoped lab PVs.
refuse_storage_cleanup() {
  local claims volumes
  claims="$(kubectl get pvc -n "$NAMESPACE" -l "$OWNER_LABEL" -o name 2>/dev/null)" || die "cannot inspect owned PVCs; refusing cleanup"
  volumes="$(kubectl get pv -l "$OWNER_LABEL,cka-lab.io/prefix=$PREFIX" -o name 2>/dev/null)" || die "cannot inspect owned PVs; refusing cleanup"
  if [[ -n "$claims$volumes" ]]; then
    log "Owned storage requires manual review before cleanup:"
    [[ -z "$claims" ]] || log "$claims"
    [[ -z "$volumes" ]] || log "$volumes"
    die "inspect data, reclaim policy and backups; explicitly remove storage yourself, then rerun. --yes does not authorize data loss"
  fi
}

has_httproutes() {
  kubectl api-resources --api-group=gateway.networking.k8s.io -o name 2>/dev/null | grep -q '^httproutes.gateway.networking.k8s.io$'
}
