# W03 Tutorial: Roll back a Deployment

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Deployment revisions allow safe rollback to known-good templates.** Inspect `kubectl -n "$NS" rollout history deployment/ember-recovery` and Pods/events to confirm the current failed image and earlier revision. Roll back this Deployment only with `kubectl -n "$NS" rollout undo deployment/ember-recovery` (or choose the known healthy revision if history indicates more than one candidate). Wait for rollout; verify template image is exactly `nginx:1.27-alpine`, one replica Available, and history still has at least two revisions. Do not roll back `ember-release` from W02 or replace the Deployment; rollback changes the Pod template and creates a new revision.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W03/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W03/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
