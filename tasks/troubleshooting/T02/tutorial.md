# T02 Tutorial: Restore the admission probe

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Readiness probes gate Service eligibility; wrong probe port keeps Pod unready while container may run.** Inspect `kubectl describe pod` and events for `sable-probe`. Edit only `web` readinessProbe: `httpGet: {path: /, port: 80}`. Preserve image nginx:1.27-alpine, selector app=sable-probe, and leave liveness untouched. Wait deployment rollout, confirm one Available replica and inspect template probe. Port 81 is the seeded fault; do not change container port/image to hide it.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T02/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T02/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
