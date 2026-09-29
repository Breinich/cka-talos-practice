# S05 Tutorial: Grow a bound disposable claim

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Expansion increases requested capacity; storage backends report completion asynchronously.** Gate on `EXPANDABLE=true` and approved disposable class, else SKIP. Create `lighthouse-live` PVC at 64Mi and reader Pod first, write receipt. Patch only that claim request to 128Mi (for example `kubectl -n "$NS" patch pvc lighthouse-live --type merge -p '{"spec":{"resources":{"requests":{"storage":"128Mi"}}}}'`). Wait until request and status.capacity both 128Mi and PVC remains Bound; leave Pod Ready and check receipt persisted. Never shrink, edit StorageClass/PV, or invoke teardown until manual data cleanup/review.

## Task-scoped workflow: capability-gated

Check this task's capability/approval first. If unavailable or unapproved, stop with SKIP; do not install optional shared infrastructure (metrics server, storage class/backend, debug permissions, or controllers). If supported, perform only the explicitly task-directed work on this task's owned resources in its unique namespace. Respect the task's data-cleanup boundary; a storage claim may require manual data review before cleanup.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
