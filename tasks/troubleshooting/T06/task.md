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

Before repair, capture the **previous** container log from the current Pod and record `{"previousMarker":"ledger-worker: startup rejected (exit 17)","container":"worker","deployment":"log-churn"}` in `.lab/T06/<namespace>/evidence/T06.json` (or `$CKA_LAB_STATE_DIR/evidence/T06.json`). Replace the failing command with a long-running sleep process; keep `busybox:1.36`. Verify one updated Available replica. A generic note mentioning logs is not evidence.

## Scope and constraints

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.
