# W04 Tutorial: Create a Job and CronJob

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Jobs and CronJobs share Pod templates but differ in scheduling.** Create both owned objects in `$NS`, with owner/task labels on objects and Pod templates. `ember-batch` uses `busybox:1.36`, completions=1, parallelism=1, restartPolicy Never and a command that prints `report-ready` once. `ember-timer` uses the same image/policy, schedule `*/10 * * * *`, `suspend: true`, successfulJobsHistoryLimit=1 and failedJobsHistoryLimit=1; its command prints `timer-ready`. A manifest is clearest: `kubectl apply -f batch.yaml` after reviewing scope. Verify Job Complete and CronJob fields with `kubectl get job,cronjob -n "$NS" -o yaml`. Suspended CronJob prevents unwanted periodic jobs; do not omit labels from nested template.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
