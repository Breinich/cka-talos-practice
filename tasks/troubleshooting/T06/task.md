# T06 — Capture the failed attempt before repair

| Field | Value |
|---|---|
| Task ID | `T06` |
| CKA pillar | `troubleshooting` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The owned `log-churn` Deployment has one `worker` container repeatedly exiting 17 after emitting `ledger-worker: startup rejected (exit 17)`.

## Required outcome

Before repair, capture the **previous** container log (`kubectl logs -p` against the current Pod) and record `{"previousMarker":"ledger-worker: startup rejected (exit 17)","container":"worker","deployment":"log-churn"}` in `.lab/T06/<namespace>/evidence/T06.json` (or `$CKA_LAB_STATE_DIR/evidence/T06.json`). Replace the failing command with `sh -c "sleep 7d"`; keep `busybox:1.36`. Verify one updated Available replica. A generic note mentioning logs is not evidence.

## Safety boundary

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.

## Validation

```bash
./tasks/troubleshooting/T06/score.sh
./tasks/troubleshooting/T06/score.sh --json
```

The two criteria are checked independently. Hints and answers remain outside task prompts under `answers/`.

From any directory, run `./tasks/troubleshooting/T06/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
