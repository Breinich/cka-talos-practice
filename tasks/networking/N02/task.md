# N02 — Publish a headless peer list

| Field | Value |
|---|---|
| Task ID | `N02` |
| CKA pillar | `networking` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

`estuary-api` already has a ready replica and a named HTTP port. Add an owned headless `estuary-peers` Service for that workload, with Service port 8080. Discover its labels and ports before creating the Service.

## Expected state

Outcome: the Service has `clusterIP: None`, selects exactly the API Pods and has a ready EndpointSlice with port 80. Inspect (use the setup namespace if unset).

## Scope and constraints

Work only in the configured lab namespace; label created resources `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=N02` (including Pod templates). Do not mutate nodes or system namespaces.
