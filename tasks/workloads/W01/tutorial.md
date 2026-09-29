# W01 Tutorial: Create a Deployment with resources

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Deployment template resources drive scheduling and container limits.** Inspect only owned `ember-api`: `kubectl -n "$NS" get deployment ember-api -o yaml` and `kubectl -n "$NS" get pods -l app=ember-api -o wide`. Edit with `kubectl -n "$NS" edit deployment ember-api`: set replicas 2; on container `api`, requests cpu `20m`, memory `32Mi`, limits cpu `100m`, memory `64Mi`. Preserve `nginx:1.27-alpine`, selector `app=ember-api`, task ownership labels. Wait via `kubectl -n "$NS" rollout status deploy/ember-api`; then check desired/ready are both 2 and template quantities exact. Avoid confusing resources on the `web` Deployment or putting `resources` at Pod rather than container level.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
