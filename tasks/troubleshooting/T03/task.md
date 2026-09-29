# T03 — Clear a scheduling dead end

| Field | Value |
|---|---|
| Task ID | `T03` |
| CKA pillar | `troubleshooting` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The owned Pod `sable-worker` requests a nonexistent node label (`cka-lab.io/nonexistent=true`); the `sleeper` container uses `busybox:1.36`.

## Required outcome

Read the scheduler event, then replace **only this owned Pod** with the same container and no nodeSelector (Pod placement fields are immutable). Confirm its selector is absent and the replacement is Running with a ready container. Never label, taint, drain or modify a node.

## Safety boundary

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.

## Validation

```bash
./tasks/troubleshooting/T03/score.sh
./tasks/troubleshooting/T03/score.sh --json
```

The two criteria are checked independently. Hints and answers remain outside task prompts under `answers/`.

From any directory, run `./tasks/troubleshooting/T03/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
