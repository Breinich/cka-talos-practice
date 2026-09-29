# T08 Tutorial: Read a metrics snapshot

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Metrics API values are live snapshots and require correct units/names.** Gate on setup capability and verify both `kubectl top nodes` and `kubectl top pods -n "$NS"` work; if either unavailable, SKIP (no install/load). Wait for seeded `web-...` Pod and metrics row. Create `$LAB/evidence/T08.sh` containing `#!/usr/bin/env bash`, `set -euo pipefail`, `kubectl top nodes`, and `kubectl top pods -n "$NS"`; make it executable and run it. Save `T08.json` as `{"node":"<actual node row>","namespace":"$NS","pod":"<actual web-... pod row>"}`. Ensure those exact named rows currently display CPU in millicores and memory in Mi; scorer queries current metrics, so pasted output is not evidence. Do not fabricate values or query another namespace.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T08/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T08/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
