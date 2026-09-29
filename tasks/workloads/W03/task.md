# W03 — Roll back a Deployment

| Field | Value |
|---|---|
| Task ID | `W03` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

Setup establishes a healthy `ember-recovery` revision, then rolls its `api` container to an unavailable image. This Deployment is separate from W02. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w03}`; use after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w03}".

## Task

Inspect rollout history and the failing Pods. Restore the earlier working `nginx:1.27-alpine` revision without changing another Deployment. Keep one replica and retained rollout history.

## Expected state

The restored image is on the Deployment; the latest generation is ready and rollout history contains at least two revisions.

## Scope and constraints

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W03` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.
