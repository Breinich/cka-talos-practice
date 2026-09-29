#!/usr/bin/env bash
set -euo pipefail
TASK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$TASK_DIR/../../../scripts/task-cli.sh" teardown T07 "$@"
