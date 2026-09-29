#!/usr/bin/env bash
# Shared helpers; bash is required by the lab scripts.
set -o errexit -o nounset -o pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${CKA_LAB_PREFIX:-cka-practice}"
NAMESPACE="${CKA_LAB_NAMESPACE:-$PREFIX}"
OWNER_LABEL="cka-lab.io/owner=cka-talos-practice"
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
