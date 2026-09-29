# W06 — Create a StatefulSet with stable identity

| Field | Value |
|---|---|
| Task ID | `W06` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The owned headless `ember-ledger` Service and its StatefulSet start with three replicas and no claims. No persistent data is involved. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w06}`; use `kubectl -n "$NAMESPACE"` after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w06}"`.

## Task

Inspect ordinal Pods, then scale only the StatefulSet down to two replicas while retaining serviceName `ember-ledger`, the matching `app=ember-ledger` selector and headless Service. Do not create/delete PVCs or PVs.

## Expected state

The StatefulSet specifies two replicas and retains its headless network identity; only ordinals `ember-ledger-0` and `ember-ledger-1` remain running and the StatefulSet reports both ready.

## Safety boundary

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W06` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.

## Validation

```bash
./tasks/workloads/W06/score.sh
./tasks/workloads/W06/score.sh --json
```

Two independent end-state criteria are scored. The validator does not repair resources or publish a solution.

From any directory, run `./tasks/workloads/W06/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
