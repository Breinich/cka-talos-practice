# W04 Tutorial: Create a Job and CronJob

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Jobs and CronJobs share Pod templates but differ in scheduling.** Create both owned objects in `$NS`, with owner/task labels on objects and Pod templates. `ember-batch` uses `busybox:1.36`, completions=1, parallelism=1, restartPolicy Never and a command that prints `report-ready` once. `ember-timer` uses the same image/policy, schedule `*/10 * * * *`, `suspend: true`, successfulJobsHistoryLimit=1 and failedJobsHistoryLimit=1; its command prints `timer-ready`. A manifest is clearest: `kubectl apply -f batch.yaml` after reviewing scope. Verify Job Complete and CronJob fields with `kubectl get job,cronjob -n "$NS" -o yaml`. Suspended CronJob prevents unwanted periodic jobs; do not omit labels from nested template.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W04/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W04/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
