# N01 — Repair the front door

| Field | Value |
|---|---|
| Task ID | `N01` |
| CKA pillar | `networking` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The estuary API Deployment is already running in the lab namespace. `estuary-front` is present on port 8080 but has no usable backends. Inspect the Deployment labels, Service selector, and EndpointSlices, then repair only this Service.

## Expected state

Outcome: its owned ClusterIP Service selects `estuary-api`, exposes port 8080 to the named HTTP container port; a ready EndpointSlice advertises port 80 and an address. Leave `estuary-catalog` and `estuary-port` for their own exercises.

## Scope and constraints

Work only in the configured lab namespace; label created resources `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=N01` (including Pod templates). Do not mutate nodes or system namespaces.
