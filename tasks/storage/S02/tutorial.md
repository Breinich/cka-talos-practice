# S02 Tutorial: Repair an offline archive binding

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Static PV/PVC binding requires matching capacity/access mode/class and explicit volume name.** Read `resources/static-broken.yaml`; substitute `__PREFIX__` and `__NAMESPACE__` from active scope. In the claim `lighthouse-archive`, change accessModes to `[ReadWriteOnce]`, request to 256Mi, retain classless `storageClassName: ""`, and `volumeName: <prefix>-lighthouse-archive`; in reader Pod change claimName to `lighthouse-archive`. Keep PV 256Mi, RWO, Retain and hostPath exactly. Save all 3 docs to S02-static.yaml. Run client dry-run only. Verify PV/PVC match and reader mount `/archive`. Never apply hostPath/PV or use Talos node path.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
