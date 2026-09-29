# N11 — Model two service exposures without applying them

| Field | Value |
|---|---|
| Task ID | `N11` |
| CKA pillar | `networking` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario

Write `.lab/N11/<namespace>/evidence/N11-services.yaml` with two owned Services in the configured namespace, then validate these local examples with a client-side dry-run only. `estuary-node-demo` models a NodePort for the API selector at Service port 8080, named HTTP target port and nodePort 30081. `estuary-alias-demo` models an ExternalName alias to `estuary.lab.invalid`.

## Expected state

Outcome: both types, ownership/scope, and exact mapping are checked independently. Do not apply the manifests: a NodePort may expose a homelab workload, and this exercise does not provision an external endpoint.

## Scope and constraints

Local artifact only under `.lab/N11/<namespace>/evidence/`; do not apply it or alter cluster/system resources. The validator reads it offline.
