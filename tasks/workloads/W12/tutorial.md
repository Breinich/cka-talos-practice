# W12 Tutorial: Use init and sidecar containers

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Init containers finish before regular containers; emptyDir is shared ephemeral storage.** Create owned Pod `ember-composed` with volume `shared: {emptyDir: {}}`. Mount it at `/shared` in init `prepare`, main, and sidecar containers. All use `busybox:1.36`: init command writes `ready` to `/shared/seed`; main verifies that file then sleeps; sidecar sleeps. The init’s successful completion permits regular containers to start. Apply a reviewed manifest to `$NS`, then check `kubectl describe pod` and `kubectl exec ... -c main -- cat /shared/seed`; Pod Ready means both regular containers ready. emptyDir is lost on Pod replacement; do not use PVC or mistake initContainers for a regular sidecar.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
