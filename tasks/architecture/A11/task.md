# A11 — Decide whether restore is permitted

| Field | Value |
|---|---|
| Task ID | `A11` |
| CKA pillar | `architecture` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 3 |

## Scenario and objective

`tasks/architecture/A11/resources/restore.json` describes three etcd members, one unavailable, a verified encrypted snapshot, and no approved maintenance window. Produce `.lab/A11/<namespace>/evidence/A11.json` with `healthyMembers`, `quorum`, `snapshotUsable` (boolean), `restoreAllowedNow` (boolean), `firstAction` (choose `investigate-member`, `restore`, or `replace-cluster`), and `snapshotPath` copied from the input. Diagnose before recovery; do not run snapshot or restore commands on Talos.

## Scope and constraints

Local artifacts only; never apply cluster-scoped definitions or rendered components. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A11` (including Pod templates). Never commit `.lab/` or credentials.
