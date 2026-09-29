# S01 Tutorial: Restore the shared workspace

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**emptyDir lifetime is Pod lifetime; volume definition is shared by mounts.** Inspect Deployment `lighthouse-workspace` and its containers/mounts. Add the existing volume name `workspace` at `/workspace` to consumer `volumeMounts`, matching producer’s `emptyDir`; preserve replica count and images. Apply/rollout and wait before writing receipt because rollout replaces Pod. Then `kubectl exec -n "$NS" deploy/lighthouse-workspace -c producer -- sh -c 'echo lighthouse-ready > /workspace/receipt'`; read same path from consumer. Verify mount names/types and exact content. Never write before rollout or use node/PV storage.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
