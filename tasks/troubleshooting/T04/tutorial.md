# T04 Tutorial: Reconnect a Service to its backends

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Service selectors are set-based matching; endpoints are generated from matching ready Pods.** Inspect `sable-route` Service selector and shared `web` Pod labels; query EndpointSlices. Change only selector to `app: web`, retain ports 80→80. Wait controller and verify a ready address under `kubernetes.io/service-name=sable-route`. Do not edit shared Deployment or endpoint object. If no endpoints, check namespace, label spelling and Pod readiness before changing ports.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T04/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T04/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
