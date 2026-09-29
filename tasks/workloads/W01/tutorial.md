# W01 Tutorial: Create a Deployment with resources

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Deployment template resources drive scheduling and container limits.** Inspect only owned `ember-api`: `kubectl -n "$NS" get deployment ember-api -o yaml` and `kubectl -n "$NS" get pods -l app=ember-api -o wide`. Edit with `kubectl -n "$NS" edit deployment ember-api`: set replicas 2; on container `api`, requests cpu `20m`, memory `32Mi`, limits cpu `100m`, memory `64Mi`. Preserve `nginx:1.27-alpine`, selector `app=ember-api`, task ownership labels. Wait via `kubectl -n "$NS" rollout status deploy/ember-api`; then check desired/ready are both 2 and template quantities exact. Avoid confusing resources on the `web` Deployment or putting `resources` at Pod rather than container level.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W01/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W01/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
