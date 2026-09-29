# S03 Tutorial: Bind a disposable data claim

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**PVC binding and consumer scheduling interact, especially with WaitForFirstConsumer.** Gate on `STORAGECLASS=true` and operator approval in capabilities.env; absent approval/backend means SKIP and no PVC. Use approved class exactly. Create owned PVC `lighthouse-live`, RWO, request 64Mi; create Pod `lighthouse-live-reader` mounting claim at `/data`, then write receipt from container. For bindingMode WaitForFirstConsumer, create Pod before expecting Bound. Verify PVC Bound with actual capacity >=64Mi and class/accessMode; verify Pod Ready and `/data/receipt` equals lighthouse-live-ready. Never alter StorageClass or teardown with claim/PV present; plan manual data cleanup.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/S03/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/storage/S03/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
