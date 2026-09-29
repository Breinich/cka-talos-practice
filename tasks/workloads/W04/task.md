# W04 — Create a Job and CronJob

| Field | Value |
|---|---|
| Task ID | `W04` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The reporting team has no batch resources yet: `ember-batch` and `ember-timer` are absent. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w04}`; use `kubectl -n "$NAMESPACE"` after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w04}"`.

## Task

Create an owned `ember-batch` Job that completes exactly once with one parallel `busybox:1.36` Pod and `restartPolicy: Never`. Create an owned `ember-timer` CronJob using that image and restart policy, schedule `*/10 * * * *`, suspend it, and retain one successful and one failed Job. Use `sh -c "echo report-ready"` for the Job and `sh -c "echo timer-ready"` for the CronJob; neither needs API access.

## Expected state

The one-shot Job reaches Complete with the required template; the CronJob has the exact suspended schedule and bounded history.

## Safety boundary

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W04` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.

## Validation

```bash
./tasks/workloads/W04/score.sh
./tasks/workloads/W04/score.sh --json
```

Two independent end-state criteria are scored. The validator does not repair resources or publish a solution.

From any directory, run `./tasks/workloads/W04/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
