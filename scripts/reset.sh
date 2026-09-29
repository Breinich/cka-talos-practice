#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/lib/common.sh"
args=("$@")
# Mirror setup/teardown scope parsing while preserving the original arguments.
i=0
while ((i < ${#args[@]})); do
  case "${args[$i]}" in
    --prefix) i=$((i+1)); PREFIX="${args[$i]:?missing prefix}"; NAMESPACE="$PREFIX";;
    --namespace) i=$((i+1)); NAMESPACE="${args[$i]:?missing namespace}";;
  esac
  i=$((i+1))
done
validate_scope
"$ROOT/scripts/teardown.sh" "${args[@]}"
# Namespace deletion is asynchronous; avoid racing setup.
for ((i=0; i<60; i++)); do kubectl get ns "$NAMESPACE" >/dev/null 2>&1 || break; sleep 1; done
kubectl get ns "$NAMESPACE" >/dev/null 2>&1 && die "namespace deletion did not finish"
rm -f "$STATE_DIR/state.env" "$STATE_DIR/before.yaml" "$STATE_DIR/capabilities.env"
"$ROOT/scripts/setup.sh" "${args[@]}"
