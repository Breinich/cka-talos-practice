# S03 Tutorial: Bind a disposable data claim

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**PVC binding and consumer scheduling interact, especially with WaitForFirstConsumer.** Gate on `STORAGECLASS=true` and operator approval in capabilities.env; absent approval/backend means SKIP and no PVC. Use approved class exactly. Create owned PVC `lighthouse-live`, RWO, request 64Mi; create Pod `lighthouse-live-reader` mounting claim at `/data`, then write receipt from container. For bindingMode WaitForFirstConsumer, create Pod before expecting Bound. Verify PVC Bound with actual capacity >=64Mi and class/accessMode; verify Pod Ready and `/data/receipt` equals lighthouse-live-ready. Never alter StorageClass or teardown with claim/PV present; plan manual data cleanup.

## Task-scoped workflow: capability-gated

Check this task's capability/approval first. If unavailable or unapproved, stop with SKIP; do not install optional shared infrastructure (metrics server, storage class/backend, debug permissions, or controllers). If supported, perform only the explicitly task-directed work on this task's owned resources in its unique namespace. Respect the task's data-cleanup boundary; a storage claim may require manual data review before cleanup.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
