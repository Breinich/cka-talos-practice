#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/common.sh"
YES=false
while (($#)); do case "$1" in --yes) YES=true;; *) die "usage: $0 [--yes]";; esac; shift; done
need kubectl; need python3
[[ -r "$STATE_DIR/state.env" ]] || die "no saved setup state at $STATE_DIR/state.env"
# shellcheck disable=SC1090
source "$STATE_DIR/state.env"
validate_scope; context_guard "$YES"
[[ "$(kubectl config current-context)" == "$CONTEXT" ]] || die "backup belongs to context $CONTEXT"
[[ "$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')" == "$SERVER" ]] || die "backup belongs to API server $SERVER"
[[ -r "$STATE_DIR/before.yaml" ]] || die "missing backup manifest; refusing cleanup"
refuse_storage_cleanup
if [[ "$NAMESPACE_EXISTED" == false ]]; then
  "$ROOT/scripts/teardown.sh" --yes --prefix "$PREFIX" --namespace "$NAMESPACE"
else
  ns_owned || die "saved namespace no longer has lab ownership; refusing restore"
  python3 "$ROOT/scripts/snapshot.py" --verify "$STATE_DIR/before.yaml" "$NAMESPACE" || die "invalid baseline; refusing cleanup"
  if grep -q '"kind": "HTTPRoute"' "$STATE_DIR/before.yaml" && ! has_httproutes; then
    die "HTTPRoute API missing; cannot restore saved routes"
  fi
  kubectl delete "$LAB_NAMESPACED_KINDS" -n "$NAMESPACE" -l "$OWNER_LABEL" --ignore-not-found=true >/dev/null
  if has_httproutes; then
    kubectl delete httproute.gateway.networking.k8s.io -n "$NAMESPACE" -l "$OWNER_LABEL" --ignore-not-found=true >/dev/null
  fi
  kubectl apply -f "$STATE_DIR/before.yaml" >/dev/null
  # Setup and live tasks do not create cluster-scoped objects. Do not remove pre-existing ones.
  log "Restored resources captured before setup in $NAMESPACE"
fi
