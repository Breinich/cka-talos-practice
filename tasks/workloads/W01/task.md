# W01 — Create a Deployment with resources

| Field | Value |
|---|---|
| Task ID | `W01` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The lab has an owned `ember-api` Deployment in the configured namespace with one replica and undersized requests. It serves a small internal HTTP endpoint. Use the task namespace (default `cka-practice-w01`).

## Task

Inspect its current Pod template. Leave two available replicas, retain `nginx:1.27-alpine` and `app=ember-api`, and set the `api` container requests to CPU `20m`, memory `32Mi`; limits must be CPU `100m`, memory `64Mi`. Do not change the shared `web` Deployment.

## Expected state

The Deployment template has the exact requests, limits, image and two replicas; both replicas are ready.

## Scope and constraints

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W01` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.
