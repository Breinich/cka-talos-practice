# N03 Tutorial: Recover a missing catalog endpoint

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**A Service with no ready EndpointSlice usually has a selector mismatch.** Compare `estuary-catalog` selector to `estuary-api` Pod template labels, then inspect Service and EndpointSlice. Change only catalog selector to `app: estuary-api`; preserve Service port 8080 and its existing named targetPort. After endpoints controller reconciles, verify slice for service-name `estuary-catalog` has ready address and port 80. Never patch EndpointSlice directly: controller recreates it from the Service selector and Pods.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/N03/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/networking/N03/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
