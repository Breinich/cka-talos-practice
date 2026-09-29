# W08 Tutorial: Apply node affinity and pod anti-affinity

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Required affinity is a hard scheduling constraint; anti-affinity spreads matching replicas by topology domain.** First inspect `kubectl get nodes --show-labels` and Ready/taint state. Patch `ember-placement` template with required node affinity `nodeSelectorTerms` matching key `node-role.kubernetes.io/worker`, operator `Exists`. Add requiredDuringSchedulingIgnoredDuringExecution pod anti-affinity with selector `app=ember-placement` and topologyKey `kubernetes.io/hostname`; retain replicas=2. Wait and check each Ready Pod’s node is a distinct eligible worker. Required, not preferred, is scored. If fewer than two eligible workers, stop and accept SKIP; never relabel nodes.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
