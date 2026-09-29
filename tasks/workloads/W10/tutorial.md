# W10 Tutorial: Configure an HPA

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**HPA uses metrics and CPU requests to compute utilization.** Gate first: require setup capability plus a responding metrics API; check `kubectl top pods -n "$NS"`. If unavailable, SKIP—do not install metrics-server or create load. Edit only copied `$LAB/evidence/W10-overlay`; render and inspect `autoscaling/v2` HPA named for target Deployment `ember-autoscale`, min=1, max=3, CPU averageUtilization=60, namespace `$NS`, ownership labels. Ensure target container CPU request 20m. When metrics responds, apply this render to `$NS`, then inspect HPA conditions for AbleToScale and target Deployment request. Compare local Kustomize output to live HPA; do not target the wrong workload or apply before checking render.

## Task-scoped workflow: capability-gated

Check this task's capability/approval first. If unavailable or unapproved, stop with SKIP; do not install optional shared infrastructure (metrics server, storage class/backend, debug permissions, or controllers). If supported, perform only the explicitly task-directed work on this task's owned resources in its unique namespace. Respect the task's data-cleanup boundary; a storage claim may require manual data review before cleanup.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
