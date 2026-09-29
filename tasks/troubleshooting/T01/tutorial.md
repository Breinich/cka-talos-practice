# T01 Tutorial: Recover the image pipeline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**ImagePullBackOff is resolved by fixing the Deployment pod template, not replacing its identity.** Inspect `kubectl -n "$NS" describe deployment sable-view`, Pods and events. Set only container `web` image to `nginx:1.27-alpine`, e.g. `kubectl -n "$NS" set image deployment/sable-view web=nginx:1.27-alpine`; retain selector `app=sable-view`. Wait rollout and verify desired/updated/available 1 and image exact. Events distinguish a missing image tag from scheduling failure; do not delete/recreate Deployment or change selector.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T01/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T01/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
