# W03 — Roll back a Deployment

| Field | Value |
|---|---|
| Task ID | `W03` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

Setup establishes a healthy `ember-recovery` revision, then rolls its `api` container to an unavailable image. This Deployment is separate from W02. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w03}`; use `kubectl -n "$NAMESPACE"` after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w03}"`.

## Task

Inspect rollout history and the failing Pods. Restore the earlier working `nginx:1.27-alpine` revision without changing another Deployment. Keep one replica and retained rollout history.

## Expected state

The restored image is on the Deployment; the latest generation is ready and rollout history contains at least two revisions.

## Safety boundary

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W03` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.

## Validation

```bash
./tasks/workloads/W03/score.sh
./tasks/workloads/W03/score.sh --json
```

Two independent end-state criteria are scored. The validator does not repair resources or publish a solution.

From any directory, run `./tasks/workloads/W03/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
