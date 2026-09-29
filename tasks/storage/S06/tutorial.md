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

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
