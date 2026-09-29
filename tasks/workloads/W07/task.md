# W07 — Use ConfigMap and Secret projections

| Field | Value |
|---|---|
| Task ID | `W07` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

A small audit consumer has not been provisioned: `ember-settings`, `ember-token` and `ember-consumer` are absent. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w07}`; use after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w07}".

## Task

Create an owned ConfigMap `ember-settings` with `MODE=audit`, an owned Opaque Secret `ember-token` with `TOKEN=dummy`, and an owned `ember-consumer` Pod using `busybox:1.36. Wire both values as environment variables by key reference, not literal values, and keep the Pod running with command. Do not print decoded Secret contents in evidence.

## Expected state

Both config objects contain the requested keys; the ready Pod references the correct objects and keys via environment variables.

## Scope and constraints

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W07` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.
