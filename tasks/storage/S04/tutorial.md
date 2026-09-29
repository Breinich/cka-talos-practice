# S04 Tutorial: Inventory storage without mutating it

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**StorageClass and CSIDriver are cluster-scoped inventories; capture complete snapshots, including empty arrays.** Query `kubectl get storageclass -o json` and `kubectl get csidriver -o json`. For each class sort by metadata.name and record name, provisioner, reclaimPolicy, volumeBindingMode, allowVolumeExpansion (false if missing), and `isDefault` only if annotation equals literal string `true`. Sort driver names. Write exactly `{ "classes": [...], "drivers": [...] }` to S04.json. Re-read and compare full list; do not include credentials or edit cluster-wide storage configuration.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/S04/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/storage/S04/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
