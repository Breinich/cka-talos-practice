# W02 Tutorial: Perform and inspect a rolling update

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**RollingUpdate controls replacement availability.** Inspect `ember-release` template, rollout strategy and history before changing. Use `kubectl -n "$NS" get deploy ember-release -o yaml`; update only `api` image to `nginx:1.27-alpine`, retaining two replicas, `maxSurge: 1`, `maxUnavailable: 0`, and revision history limit 3. A strategic patch may use `kubectl -n "$NS" set image deployment/ember-release api=nginx:1.27-alpine`; confirm strategy remains unchanged, then `kubectl -n "$NS" rollout status deployment/ember-release`. Check observed generation/latest revision and two Ready replicas. Do not scale down or set maxUnavailable positive.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
