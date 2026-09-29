# W02 Tutorial: Perform and inspect a rolling update

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**RollingUpdate controls replacement availability.** Inspect `ember-release` template, rollout strategy and history before changing. Use `kubectl -n "$NS" get deploy ember-release -o yaml`; update only `api` image to `nginx:1.27-alpine`, retaining two replicas, `maxSurge: 1`, `maxUnavailable: 0`, and revision history limit 3. A strategic patch may use `kubectl -n "$NS" set image deployment/ember-release api=nginx:1.27-alpine`; confirm strategy remains unchanged, then `kubectl -n "$NS" rollout status deployment/ember-release`. Check observed generation/latest revision and two Ready replicas. Do not scale down or set maxUnavailable positive.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W02/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W02/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
