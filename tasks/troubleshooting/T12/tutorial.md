# T12 Tutorial: Inspect Pod namespaces without host access

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Ephemeral containers provide constrained debugging without host namespaces.** Gate on permission to update `pods/ephemeralcontainers`; absent authorization means SKIP, do not elevate/install. For owned `toolbox`, run targeted `kubectl debug -n "$NS" pod/toolbox -it --target=toolbox --image=busybox:1.36 --container=inspect-<suffix> -- sh -c 'cat /proc/net/route; cat /proc/1/status'` (ensure no `--copy-to`, node target, host namespace, or sysadmin profile). Then inspect ephemeral container status/logs: it must terminate exit 0 and output route headers Iface/Destination and process Name. Debug is task-scoped; do not use host access.

## Task-scoped workflow: capability-gated

Check this task's capability/approval first. If unavailable or unapproved, stop with SKIP; do not install optional shared infrastructure (metrics server, storage class/backend, debug permissions, or controllers). If supported, perform only the explicitly task-directed work on this task's owned resources in its unique namespace. Respect the task's data-cleanup boundary; a storage claim may require manual data review before cleanup.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
