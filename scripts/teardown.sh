#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/common.sh"
YES=false
while (($#)); do
  case "$1" in --yes) YES=true;; --prefix) shift; PREFIX="${1:?}"; NAMESPACE="$PREFIX";; --namespace) shift; NAMESPACE="${1:?}";; *) die "usage: $0 [--yes] [--prefix NAME] [--namespace NAME]";; esac
  shift
done
need kubectl; need python3; validate_scope; context_guard "$YES"
if [[ -r "$STATE_DIR/state.env" ]] && grep -qx NAMESPACE_EXISTED=true "$STATE_DIR/state.env"; then
  die "namespace existed before setup; use restore.sh instead of deleting it"
fi
refuse_storage_cleanup
if kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
  ns_owned || die "refusing to delete namespace without $OWNER_LABEL"
  OWNED_SERVICES="$(kubectl get service -n "$NAMESPACE" -l "$OWNER_LABEL" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')" || die "cannot inspect owned Services; refusing deletion"
  export OWNED_SERVICES
  kinds="$(kubectl api-resources --namespaced=true --verbs=list -o name)" || die "cannot discover namespaced resources; refusing deletion"
  [[ -n "$kinds" ]] || die "empty API discovery; refusing deletion"
  while IFS= read -r kind; do
    kubectl get "$kind" -n "$NAMESPACE" -o json | python3 "$ROOT/scripts/snapshot.py" --assert-owned || die "cannot verify ownership of $kind; refusing namespace deletion"
  done <<<"$kinds"
  kubectl delete namespace "$NAMESPACE" --wait=false
else
  log "Namespace $NAMESPACE is already absent"
fi
# Cluster-scoped RBAC is simulation-only; never delete pre-existing objects.
log "Teardown requested only for lab-owned resources. State backup remains in $STATE_DIR."
