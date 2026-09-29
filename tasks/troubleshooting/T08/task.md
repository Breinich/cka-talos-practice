# T08 — Read a metrics snapshot

| Field | Value |
|---|---|
| Task ID | `T08` |
| CKA pillar | `troubleshooting` |
| Mode | `conditional` |
| Capability | `metrics` |
| Points | 2 |

## Scenario

Setup seeds an owned `web` Deployment in this task's isolated namespace. This is **conditional** on the setup metrics capability: the Metrics API must serve both nodes and namespaced Pods. Wait for a `web-...` Pod to run and appear in. No load generation or metrics installation is authorized.

## Required outcome

In a local shell script, collect both node and Pod metric snapshots at `.lab/T08/<namespace>/evidence/T08.sh` (or `$CKA_LAB_STATE_DIR/evidence/T08.sh`). Save `T08.json` with `node` (one actual node name), `namespace` (configured lab namespace), and `pod` (an actual `web-...` Pod name). Confirm that each named row exposes CPU in millicores and memory in Mi; the scorer reads current metrics, not pasted keywords. If metrics is unavailable, expect SKIP.

## Scope and constraints

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.
