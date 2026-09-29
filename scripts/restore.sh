#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/common.sh"
YES=false
while (($#)); do case "$1" in --yes) YES=true;; *) die "usage: $0 [--yes]";; esac; shift; done
need kubectl
[[ -r "$STATE_DIR/state.env" ]] || die "no saved setup state at $STATE_DIR/state.env"
# shellcheck disable=SC1090
source "$STATE_DIR/state.env"
validate_scope; context_guard "$YES"
[[ "$(kubectl config current-context)" == "$CONTEXT" ]] || die "backup belongs to context $CONTEXT"
[[ "$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')" == "$SERVER" ]] || die "backup belongs to API server $SERVER"
if [[ "$NAMESPACE_EXISTED" == false ]]; then
  "$ROOT/scripts/teardown.sh" --yes --prefix "$PREFIX" --namespace "$NAMESPACE"
else
  ns_owned || die "saved namespace no longer has lab ownership; refusing restore"
  kubectl delete all,configmap,secret,serviceaccount,role.rbac.authorization.k8s.io,rolebinding.rbac.authorization.k8s.io,pvc,networkpolicy \
    -n "$NAMESPACE" -l "$OWNER_LABEL" --ignore-not-found=true >/dev/null
  kubectl apply -f "$STATE_DIR/before.yaml" >/dev/null
  for kind in persistentvolume clusterrole clusterrolebinding; do
    kubectl delete "$kind" -l "$OWNER_LABEL,cka-lab.io/prefix=$PREFIX" --ignore-not-found=true 2>/dev/null || true
  done
  log "Restored resources captured before setup in $NAMESPACE"
fi
