# S04 — Inventory storage without mutating it

| Field | Value |
|---|---|
| Task ID | `S04` |
| CKA pillar | `storage` |
| Mode | `read-only` |
| Capability | `core` |
| Points | 2 |

## Scenario

A Lighthouse operator needs an exact storage inventory before approving any persistent lab data. Inspect the live `storageclass` and `csidriver` lists (including when either list is empty), then save `.lab/S04/<namespace>/evidence/S04.json` with exactly two keys: `classes` (sorted by name) and `drivers` (sorted names). For each class record `name`, `provisioner`, `reclaimPolicy`, `volumeBindingMode`, boolean `allowVolumeExpansion` (missing means false), and boolean `isDefault` (annotation `storageclass.kubernetes.io/is-default-class` equals the string `true`). Record driver names in `drivers.

## Scope and constraints

Read-only: do not edit any cluster-scoped resource. Do not include storage credentials or secrets.
