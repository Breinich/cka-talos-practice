# W03 Tutorial: Roll back a Deployment

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Deployment revisions allow safe rollback to known-good templates.** Inspect `kubectl -n "$NS" rollout history deployment/ember-recovery` and Pods/events to confirm the current failed image and earlier revision. Roll back this Deployment only with `kubectl -n "$NS" rollout undo deployment/ember-recovery` (or choose the known healthy revision if history indicates more than one candidate). Wait for rollout; verify template image is exactly `nginx:1.27-alpine`, one replica Available, and history still has at least two revisions. Do not roll back `ember-release` from W02 or replace the Deployment; rollback changes the Pod template and creates a new revision.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
