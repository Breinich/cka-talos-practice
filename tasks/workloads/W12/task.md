# W12 — Use init and sidecar containers

| Field | Value |
|---|---|
| Task ID | `W12` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

A single-Pod composition exercise has no starting Pod. The `ember-composed` Pod must share ephemeral files; no persistent volumes are allowed. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w12}`; use after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w12}".

## Task

Create an owned Pod with `emptyDir` named `shared` mounted at `/shared` by three `busybox:1.36` containers: init `prepare` runs; `main` runs; long-running `sidecar` runs.

## Expected state

The init/main/sidecar and mounts share one emptyDir; the Pod reaches Ready after the init writes the marker and both regular containers run.

## Scope and constraints

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W12` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.
