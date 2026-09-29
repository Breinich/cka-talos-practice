# S01 — Restore the shared workspace

| Field | Value |
|---|---|
| Task ID | `S01` |
| CKA pillar | `storage` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The Lighthouse relay has one `lighthouse-workspace` Deployment in the lab namespace. Its `producer` already mounts an `emptyDir` at `/workspace`; its `consumer` cannot see that directory. Inspect the template, then repair the owned Deployment without changing its replica count or container images. After the rollout, write the literal `lighthouse-ready` to `/workspace/receipt` from `producer`. The two independently checked outcomes are: both containers mount the same `emptyDir` at `/workspace`, and the Ready consumer can read that exact receipt. A Pod restart resets emptyDir contents; write the receipt *after* the repaired rollout.

## Safety boundary

Only the owned namespace-scoped Deployment may be changed. No node filesystem or PV is involved.

## Validation

```bash
./tasks/storage/S01/score.sh
./tasks/storage/S01/score.sh --json
```

The scorer checks two end-state criteria without printing a solution. `SKIP` excludes unavailable conditional storage from the denominator.

From any directory, run `./tasks/storage/S01/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
