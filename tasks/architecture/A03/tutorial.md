# A03 Tutorial: Repair a restricted reader

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Least-privilege RBAC.** Role rules are additive; RoleBinding subjects determine who gets them. Edit only namespaced Role `relay-reader`, preserving RoleBinding `relay-reader` and its ServiceAccount subject.

Inspect both objects: `kubectl -n "$NS" get role relay-reader,rolebinding relay-reader -o yaml`. Set the Role rule to `apiGroups: [""]`, `resources: ["pods"]`, `verbs: ["get","list","watch"]`; no Secrets rule and no create/patch/delete verbs. For example, patch the existing rule declaratively with `kubectl -n "$NS" edit role relay-reader` and save. Verify using `kubectl auth can-i list pods --as=system:serviceaccount:$NS:relay-identity -n "$NS"` and repeat for delete pods and get secrets (both no). Do not recreate the binding or broaden to ClusterRole.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
