# W12 Tutorial: Use init and sidecar containers

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Init containers finish before regular containers; emptyDir is shared ephemeral storage.** Create owned Pod `ember-composed` with volume `shared: {emptyDir: {}}`. Mount it at `/shared` in init `prepare`, main, and sidecar containers. All use `busybox:1.36`: init command writes `ready` to `/shared/seed`; main verifies that file then sleeps; sidecar sleeps. The init’s successful completion permits regular containers to start. Apply a reviewed manifest to `$NS`, then check `kubectl describe pod` and `kubectl exec ... -c main -- cat /shared/seed`; Pod Ready means both regular containers ready. emptyDir is lost on Pod replacement; do not use PVC or mistake initContainers for a regular sidecar.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W12/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W12/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
