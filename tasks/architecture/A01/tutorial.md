# A01 Tutorial: Read the live discovery surface

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Discovery API and scope.** Kubernetes discovery tells you whether an operation needs a namespace; Pod and Role are namespaced resources. No object mutation is called for.

Set `NS` from the active context, then collect only the version and discovery data: `kubectl version -o json`; `kubectl api-resources --namespaced=true`; `kubectl api-resources --api-group=rbac.authorization.k8s.io`. Build `.lab/A01/$NS/evidence/A01.json` with exactly `serverVersion` from `.serverVersion.gitVersion`, `podNamespaced: true`, and `roleGroup: "rbac.authorization.k8s.io"`. Do not dump kubeconfig. Verify the stored version is the server version, not client version, and both resource-discovery facts agree.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
