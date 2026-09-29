# W13 — Protect availability during disruptions

| Field | Value |
|---|---|
| Task ID | `W13` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

This task seeds its own two-replica `ember-api` Deployment, independently of W01. There is no disruption budget for this Deployment. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w13}`; use `kubectl -n "$NAMESPACE"` after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w13}"`.

## Task

Create an owned PodDisruptionBudget `ember-api` selecting only `app=ember-api`, with `minAvailable: 1`. Ensure this Deployment remains healthy before checking permitted disruptions; do not drain or evict a node.

## Expected state

The budget selects the correct Pods and minimum; with two healthy target replicas, the budget reports at least one disruption allowed.

## Safety boundary

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W13` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.

## Validation

```bash
./tasks/workloads/W13/score.sh
./tasks/workloads/W13/score.sh --json
```

Two independent end-state criteria are scored. The validator does not repair resources or publish a solution.

From any directory, run `./tasks/workloads/W13/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
