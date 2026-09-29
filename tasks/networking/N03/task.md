# N03 — Recover a missing catalog endpoint

| Field | Value |
|---|---|
| Task ID | `N03` |
| CKA pillar | `networking` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The `estuary-catalog` Service already exists but its EndpointSlice has no ready API address. Compare its selector with the running `estuary-api` Deployment; repair only `estuary-catalog.

## Expected state

Outcome: the Service remains on port 8080 with its named backend port, selects the API workload, and its ready EndpointSlice contains an address and port 80. Do not edit the controller-generated EndpointSlice directly.

## Scope and constraints

Work only in the configured lab namespace; label created resources `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=N03` (including Pod templates). Do not mutate nodes or system namespaces.
