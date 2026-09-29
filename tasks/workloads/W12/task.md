# W12 — Use init and sidecar containers

| Field | Value |
|---|---|
| Task ID | `W12` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

A single-Pod composition exercise has no starting Pod. The `ember-composed` Pod must share ephemeral files; no persistent volumes are allowed. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w12}`; use `kubectl -n "$NAMESPACE"` after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w12}"`.

## Task

Create an owned Pod with `emptyDir` named `shared` mounted at `/shared` by three `busybox:1.36` containers: init `prepare` runs `sh -c "echo ready > /shared/seed"`; `main` runs `sh -c "test -f /shared/seed && sleep 7d"`; long-running `sidecar` runs `sh -c "sleep 7d"`.

## Expected state

The init/main/sidecar and mounts share one emptyDir; the Pod reaches Ready after the init writes the marker and both regular containers run.

## Safety boundary

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W12` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.

## Validation

```bash
./tasks/workloads/W12/score.sh
./tasks/workloads/W12/score.sh --json
```

Two independent end-state criteria are scored. The validator does not repair resources or publish a solution.

From any directory, run `./tasks/workloads/W12/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
