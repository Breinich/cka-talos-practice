# T03 Tutorial: Clear a scheduling dead end

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Pod scheduling constraints are immutable; replace the owned Pod rather than mutate a node.** Inspect `kubectl -n "$NS" describe pod sable-worker` for FailedScheduling and missing selector label. Preserve `sleeper` busybox:1.36 and other intended spec fields; remove nodeSelector `cka-lab.io/nonexistent=true`. Since it is a standalone Pod, capture its YAML, delete only `sable-worker`, then recreate corrected Pod (or use controlled manifest replacement). Verify nodeSelector absent and Pod Running/Ready. Never label, taint or drain nodes; no Deployment controller exists to replace it.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T03/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T03/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
