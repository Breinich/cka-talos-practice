#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
(($# >= 2)) || { echo 'usage: task-cli.sh setup|score|teardown|reset ID [options]' >&2; exit 2; }
action="$1" id="$2"; shift 2
row="$(awk -F '\t' -v id="$id" 'NR>1 && $1==id {print $2; exit}' "$ROOT/metadata/tasks.tsv")"
[[ -n "$row" ]] || { echo "unknown task ID: $id" >&2; exit 2; }
case "$action" in setup|score|teardown|reset) ;; *) echo "unknown action: $action" >&2; exit 2;; esac
prefix="${CKA_LAB_PREFIX:-cka-practice}"; ns="${CKA_LAB_NAMESPACE:-}"; args=("$@")
for ((i=0;i<${#args[@]};i++)); do
  case "${args[i]}" in
    --prefix) ((i+=1)); prefix="${args[i]:?missing prefix}";;
    --namespace) ((i+=1)); ns="${args[i]:?missing namespace}";;
  esac
done
ns="${ns:-$prefix-${id,,}}"
export CKA_TASK_STATE_ROOT="${CKA_TASK_STATE_ROOT:-${CKA_LAB_STATE_DIR:-$ROOT/.lab}}"
export CKA_LAB_PREFIX="$prefix" CKA_LAB_NAMESPACE="$ns" CKA_LAB_STATE_DIR="$CKA_TASK_STATE_ROOT/$id/$ns"
export CKA_TASK_RESOURCES="$ROOT/tasks/$row/$id/resources"
if [[ "$action" == score ]]; then
  [[ $# -eq 0 || $# -eq 1 && "$1" == --json ]] || { echo 'usage: score.sh [--json]' >&2; exit 2; }
  exec "$ROOT/scripts/validate.sh" --task "$id" "$@"
fi
python3 "$ROOT/scripts/task-lifecycle.py" "$action" "$id" "$@"
if [[ "$action" == setup || "$action" == reset ]] && [[ "$id" == A07 ]]; then
  if command -v helm >/dev/null 2>&1; then printf 'HELM=true\n' >"$CKA_LAB_STATE_DIR/capabilities.env"; fi
fi
