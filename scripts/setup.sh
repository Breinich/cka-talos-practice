#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
(($#)) || { echo 'usage: $0 TASK_ID [--yes] [--prefix NAME] [--namespace NAME]' >&2; exit 2; }
id="$1"; shift
exec "$ROOT/scripts/task-cli.sh" setup "$id" "$@"
