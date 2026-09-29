# S06 Tutorial: Protect an offline records volume

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Retain reclaim policy protects backing volume after claim deletion; access mode must match on both ends.** Start with `resources/reclaim-broken.yaml`, replace prefix/namespace placeholders. Keep PV `__PREFIX__-lighthouse-records`, hostPath `/var/local/lighthouse-records`, 128Mi, classless explicit binding. Change PV policy `Delete` to `Retain`; set PVC `lighthouse-records` accessModes to `[ReadWriteOnce]`, matching PV, preserve volumeName and 128Mi request. The edited critical fields must be:

```yaml
# PersistentVolume
spec:
  capacity: {storage: 128Mi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  hostPath: {path: /var/local/lighthouse-records, type: DirectoryOrCreate}
---
# PersistentVolumeClaim
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: ""
  volumeName: <active-prefix>-lighthouse-records
  resources: {requests: {storage: 128Mi}}
```

Keep source names and labels, render namespace/prefix placeholders, save both docs to S06-reclaim.yaml, and inspect locally with client dry-run if useful. Verify capacity/access/binding and Retain. Never apply hostPath volume or delete claim/PV, especially on Talos.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/S06/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/storage/S06/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
