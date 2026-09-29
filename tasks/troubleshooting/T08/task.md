# T08 — Read a metrics snapshot

| Field | Value |
|---|---|
| Task ID | `T08` |
| CKA pillar | `troubleshooting` |
| Mode | `conditional` |
| Capability | `metrics` |
| Points | 2 |

## Scenario

Setup seeds an owned `web` Deployment in this task's isolated namespace. This is **conditional** on the setup metrics capability: the Metrics API must serve both nodes and namespaced Pods. Wait for a `web-...` Pod to run and appear in `kubectl top pods -n <lab-namespace>`. No load generation or metrics installation is authorized.

## Required outcome

Use `kubectl top nodes` and `kubectl top pods -n <lab-namespace>` in a local shell script at `.lab/T08/<namespace>/evidence/T08.sh` (or `$CKA_LAB_STATE_DIR/evidence/T08.sh`). Save `T08.json` with `node` (one actual node name), `namespace` (configured lab namespace), and `pod` (an actual `web-...` Pod name). Confirm that each named row exposes CPU in millicores and memory in Mi; the scorer reads current metrics, not pasted keywords. If metrics is unavailable, expect SKIP.

## Safety boundary

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.

## Validation

```bash
./tasks/troubleshooting/T08/score.sh
./tasks/troubleshooting/T08/score.sh --json
```

The two criteria are checked independently. Hints and answers remain outside task prompts under `answers/`.

From any directory, run `./tasks/troubleshooting/T08/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
