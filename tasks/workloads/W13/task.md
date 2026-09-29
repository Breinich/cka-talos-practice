# W13 — Protect availability during disruptions

| Field | Value |
|---|---|
| Task ID | `W13` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

This task seeds its own two-replica `ember-api` Deployment, independently of W01. There is no disruption budget for this Deployment. Use the task namespace (default `cka-practice-w13`).

## Task

Create an owned PodDisruptionBudget `ember-api` selecting only `app=ember-api`, with `minAvailable: 1`. Ensure this Deployment remains healthy before checking permitted disruptions; do not drain or evict a node.

## Expected state

The budget selects the correct Pods and minimum; with two healthy target replicas, the budget reports at least one disruption allowed.

## Scope and constraints

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W13` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.
