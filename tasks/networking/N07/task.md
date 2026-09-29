# N07 — Translate the entrypoint into header routing

| Field | Value |
|---|---|
| Task ID | `N07` |
| CKA pillar | `networking` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario

Using your N06 migration input, draft `.lab/N07/<namespace>/evidence/N07-route.yaml`, an owned namespaced Gateway API HTTPRoute `estuary-route` for `estuary.lab.invalid`. Its hypothetical parent is `estuary-gateway`, listener `http`; this Gateway and its CRDs are deliberately **not** installed by the lab.

## Expected state

Outcome: `/v1` requests with exact header `x-estuary-tier: canary` route to `estuary-port:8080`, while other `/v1` requests route to `estuary-front:8080`. Give the header-specific rule precedence.

## Scope and constraints

Local artifact only under `.lab/N07/<namespace>/evidence/`; do not apply it or alter cluster/system resources. The validator reads it offline.
