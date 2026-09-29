# S04 — Inventory storage without mutating it

| Field | Value |
|---|---|
| Task ID | `S04` |
| CKA pillar | `storage` |
| Mode | `read-only` |
| Capability | `core` |
| Points | 2 |

## Scenario

A Lighthouse operator needs an exact storage inventory before approving any persistent lab data. Inspect the live `storageclass` and `csidriver` lists (including when either list is empty), then save `.lab/S04/<namespace>/evidence/S04.json` with exactly two keys: `classes` (sorted by name) and `drivers` (sorted names). For each class record `name`, `provisioner`, `reclaimPolicy`, `volumeBindingMode`, boolean `allowVolumeExpansion` (missing means false), and boolean `isDefault` (annotation `storageclass.kubernetes.io/is-default-class` equals the string `true`). Record driver names in `drivers`. The scorer compares both complete lists separately to fresh API reads, not to keyword evidence.

## Safety boundary

Read-only: do not edit any cluster-scoped resource. Do not include storage credentials or secrets.

## Validation

```bash
./tasks/storage/S04/score.sh
./tasks/storage/S04/score.sh --json
```

The scorer checks two end-state criteria without printing a solution. `SKIP` excludes unavailable conditional storage from the denominator.

From any directory, run `./tasks/storage/S04/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
