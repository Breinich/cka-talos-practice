# W05 — Create a node-spanning DaemonSet

| Field | Value |
|---|---|
| Task ID | `W05` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

There is no `ember-observer` DaemonSet. Eligible nodes are Ready, schedulable workers labeled `node-role.kubernetes.io/worker`; do not touch nodes. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w05}`; use `kubectl -n "$NAMESPACE"` after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w05}"`.

## Task

Discover the eligible workers. Create an owned `ember-observer` DaemonSet selecting `app=ember-observer`, targeting only worker-labeled nodes and using `busybox:1.36` with CPU `5m`/memory `8Mi` requests and command `sh -c "sleep 7d"`. Do not add a toleration that bypasses taints.

## Expected state

The Pod template targets workers with tiny requests; exactly one ready Pod runs per eligible worker. If none exist this exercise is SKIP.

## Safety boundary

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W05` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.

## Validation

```bash
./tasks/workloads/W05/score.sh
./tasks/workloads/W05/score.sh --json
```

Two independent end-state criteria are scored. The validator does not repair resources or publish a solution.

From any directory, run `./tasks/workloads/W05/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
