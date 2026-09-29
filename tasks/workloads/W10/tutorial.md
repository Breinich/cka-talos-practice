# W10 Tutorial: Configure an HPA

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**HPA uses metrics and CPU requests to compute utilization.** Gate first: require setup capability plus a responding metrics API; check `kubectl top pods -n "$NS"`. If unavailable, SKIP—do not install metrics-server or create load. Edit only copied `$LAB/evidence/W10-overlay`; render and inspect `autoscaling/v2` HPA named for target Deployment `ember-autoscale`, min=1, max=3, CPU averageUtilization=60, namespace `$NS`, ownership labels. Ensure target container CPU request 20m. When metrics responds, apply this render to `$NS`, then inspect HPA conditions for AbleToScale and target Deployment request. Compare local Kustomize output to live HPA; do not target the wrong workload or apply before checking render.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W10/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W10/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
