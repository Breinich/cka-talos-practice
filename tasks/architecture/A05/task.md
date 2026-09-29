# A05 — Check both sides of the permission boundary

| Field | Value |
|---|---|
| Task ID | `A05` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

After repairing A03, the relay identity must list Pods but must not delete Pods. Investigate with `kubectl auth can-i` impersonating `system:serviceaccount:<namespace>:relay-identity` in the active namespace. The scorer queries authorization directly, rather than accepting a written yes/no claim. Do not grant extra permissions to make the checks pass.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a05`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; `.lab/A05/<namespace>/state.json` records their values.

## Safety boundary

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A05` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A05/score.sh
./tasks/architecture/A05/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A05/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
