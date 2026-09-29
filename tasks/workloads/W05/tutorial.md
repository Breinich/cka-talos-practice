# W05 Tutorial: Create a node-spanning DaemonSet

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**DaemonSets schedule one Pod per eligible node matching their template constraints.** Discover Ready, schedulable worker-labeled nodes: `kubectl get nodes -l node-role.kubernetes.io/worker -o wide` and inspect taints. Create owned DaemonSet `ember-observer`, selector/template `app=ember-observer`, `nodeSelector: {node-role.kubernetes.io/worker: ""}`, container `busybox:1.36`, command sleeping 7d, requests cpu `5m`/memory `8Mi`; do not add tolerations. Apply manifest to `$NS`, then compare desiredNumberScheduled/currentNumberScheduled/numberReady to count of eligible workers and inspect Pod placement. If none eligible, capability is unavailable/skip. Never label or taint nodes to force scheduling.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
