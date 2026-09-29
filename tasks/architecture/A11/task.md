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

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a11`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A11/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Local artifacts only; never apply cluster-scoped definitions or rendered components. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A11` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A11/score.sh
./tasks/architecture/A11/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A11/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
