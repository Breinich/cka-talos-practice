# W06 Tutorial: Create a StatefulSet with stable identity

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**StatefulSet ordinal identity is provided by its headless governing Service.** Inspect `ember-ledger` and `ember-ledger` StatefulSet, then scale only the StatefulSet to two replicas: `kubectl -n "$NS" scale statefulset/ember-ledger --replicas=2`. Preserve `serviceName: ember-ledger`, selector `app=ember-ledger`, and headless Service (`clusterIP: None`). Check `kubectl -n "$NS" get sts,pods -o wide`: replicas 2/2 Ready, Pods `ember-ledger-0` and `-1`, ordinal 2 gone. No PVCs are in this exercise; do not create/delete storage claims or alter the Service.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
