# W10 — Configure an HPA

| Field | Value |
|---|---|
| Task ID | `W10` |
| CKA pillar | `workloads` |
| Mode | `conditional` |
| Capability | `metrics` |
| Points | 2 |

## Scenario

Metrics API availability varies. The owned `ember-autoscale` Deployment has CPU requests already seeded; no HPA is seeded. Use the task namespace (default `cka-practice-w10`).

## Task

Setup copies `tasks/workloads/W10/resources/hpa/` to `.lab/W10/<namespace>/evidence/W10-overlay`. Edit this instance's local Kustomize overlay so its rendered, owned autoscaling/v2 HPA is in the configured namespace, targets Deployment `ember-autoscale`, and uses CPU utilization 60%, min 1 and max 3. Inspect the rendered output; only when metrics actually respond, apply that render in the lab namespace. Ensure the target container has CPU request `20m`; wait for AbleToScale. Do not drive artificial load.

## Expected state

The local Kustomize render exactly matches the live owned HPA target, bounds and utilization; the HPA reports AbleToScale and its target has the expected request. When metrics are absent this task SKIPs.

## Scope and constraints

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W10` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.
