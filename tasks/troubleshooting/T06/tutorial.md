# T06 Tutorial: Capture the failed attempt before repair

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Previous logs disappear when restarting/replacing a failing container, so capture first.** Locate current `log-churn` Pod and run `kubectl logs -n "$NS" <pod> -c worker --previous`; confirm marker `ledger-worker: startup rejected (exit 17)`. Save exact JSON `{"previousMarker":"ledger-worker: startup rejected (exit 17)","container":"worker","deployment":"log-churn"}` before editing. Then change worker command to `sh -c "sleep 7d"`, keep busybox:1.36, wait Deployment Available. Verify evidence exact and one updated replica. Do not capture only current logs after repair or generic note.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T06/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T06/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
