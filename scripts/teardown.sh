#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/common.sh"
YES=false
while (($#)); do
  case "$1" in --yes) YES=true;; --prefix) shift; PREFIX="${1:?}"; NAMESPACE="$PREFIX";; --namespace) shift; NAMESPACE="${1:?}";; *) die "usage: $0 [--yes] [--prefix NAME] [--namespace NAME]";; esac
  shift
done
need kubectl; validate_scope; context_guard "$YES"
if kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
  ns_owned || die "refusing to delete namespace without $OWNER_LABEL"
  kubectl delete namespace "$NAMESPACE" --wait=false
else
  log "Namespace $NAMESPACE is already absent"
fi
# Remove only explicitly lab-owned cluster-scoped exercise objects.
for kind in persistentvolume clusterrole clusterrolebinding; do
  kubectl delete "$kind" -l "$OWNER_LABEL,cka-lab.io/prefix=$PREFIX" --ignore-not-found=true 2>/dev/null || true
done
log "Teardown requested only for lab-owned resources. State backup remains in $STATE_DIR."
