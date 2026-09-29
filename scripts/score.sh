#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
(($#)) || { echo 'usage: score.sh TASK_ID [--json]' >&2; exit 2; }
id="$1"; shift
exec "$ROOT/scripts/task-cli.sh" score "$id" "$@"
