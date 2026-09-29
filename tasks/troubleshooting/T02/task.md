# T02 — Restore the admission probe

| Field | Value |
|---|---|
| Task ID | `T02` |
| CKA pillar | `troubleshooting` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The `sable-probe` Deployment serves HTTP on port 80, but its one Pod never becomes Ready. Its seeded probe uses `/` on port 81.

## Required outcome

Inspect Pod conditions and events. Repair only the `web` HTTP readiness probe to use `/` on port 80; keep image `nginx:1.27-alpine` and selector `app=sable-probe`. Verify the corrected template and one updated Available replica.

## Safety boundary

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.

## Validation

```bash
./tasks/troubleshooting/T02/score.sh
./tasks/troubleshooting/T02/score.sh --json
```

The two criteria are checked independently. Hints and answers remain outside task prompts under `answers/`.

From any directory, run `./tasks/troubleshooting/T02/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
