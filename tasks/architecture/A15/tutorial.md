# A15 Tutorial: Inventory admission without changing it

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Pod Security Admission labels are namespaced; webhook inventory is cluster-scoped and read-only.** Change only the dedicated task namespace enforcement label.

Inspect counts with `kubectl get validatingwebhookconfigurations -o name` and mutating equivalent; inspect namespace labels with `kubectl get ns "$NS" --show-labels`. Set only `pod-security.kubernetes.io/enforce=baseline` on `$NS` (e.g. `kubectl label namespace "$NS" pod-security.kubernetes.io/enforce=baseline --overwrite`). Write fresh counts and label to `$LAB/evidence/A15.json`. Verify existing audit/warn labels stay baseline and counts equal current lists. Do not edit webhook configurations or submit a privileged probe.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
