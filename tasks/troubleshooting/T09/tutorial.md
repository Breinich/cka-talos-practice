# T09 Tutorial: Build a node pressure inventory

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Node conditions, taints and allocatable are different from raw capacity.** Read `kubectl get nodes` and choose one real node, then `kubectl get node "$NODE" -o json`. Build T09.json with exact status strings for Ready/MemoryPressure/DiskPressure/PIDPressure, spec taints or [], and `capacity`/`allocatable` each containing exact CPU and memory quantity strings. Verify no unit normalization/rounding, preserve nil taints as empty array, and compare against same node fresh read. Read-only only; do not patch node or induce pressure.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T09/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T09/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
