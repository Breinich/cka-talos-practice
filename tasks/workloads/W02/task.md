# W02 — Perform and inspect a rolling update

| Field | Value |
|---|---|
| Task ID | `W02` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The owned `ember-release` Deployment starts on `nginx:1.26-alpine`, two replicas, with a RollingUpdate strategy and three retained revisions. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w02}`; use `kubectl -n "$NAMESPACE"` after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w02}"`.

## Task

Inspect the current image and strategy; roll the `api` container forward to `nginx:1.27-alpine`. Preserve two replicas, `maxSurge: 1` and `maxUnavailable: 0`. Wait for rollout completion.

## Expected state

The new image and strategy are on the template; the controller observes the latest generation with two ready replicas.

## Safety boundary

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W02` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.

## Validation

```bash
./tasks/workloads/W02/score.sh
./tasks/workloads/W02/score.sh --json
```

Two independent end-state criteria are scored. The validator does not repair resources or publish a solution.

From any directory, run `./tasks/workloads/W02/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
