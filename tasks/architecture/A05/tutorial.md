# A05 Tutorial: Check both sides of the permission boundary

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Authorization checks answer effective permissions.** `can-i` evaluates the complete authorization chain; it is better evidence than reading a Role alone. This is a read-only check of the seeded identity.

Set the impersonated user exactly to `system:serviceaccount:$NS:relay-identity`. Run `kubectl auth can-i list pods --as="$USER" -n "$NS"` and `kubectl auth can-i delete pods --as="$USER" -n "$NS"`. Expected answers are `yes` and `no`. Also inspect the RoleBinding subject if results differ. Do not change RBAC just to make a response match; this check assumes A03’s least-privilege role state and makes no API edits.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
