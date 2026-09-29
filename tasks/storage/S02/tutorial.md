# S02 Tutorial: Repair an offline archive binding

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Static PV/PVC binding requires matching capacity/access mode/class and explicit volume name.** Read `resources/static-broken.yaml`; substitute `__PREFIX__` and `__NAMESPACE__` from active scope. In the claim `lighthouse-archive`, change accessModes to `[ReadWriteOnce]`, request to 256Mi, retain classless `storageClassName: ""`, and `volumeName: <prefix>-lighthouse-archive`; in reader Pod change claimName to `lighthouse-archive`. Keep PV 256Mi, RWO, Retain and hostPath exactly. Save all 3 docs to S02-static.yaml. Run client dry-run only. Verify PV/PVC match and reader mount `/archive`. Never apply hostPath/PV or use Talos node path.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/S02/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/storage/S02/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
