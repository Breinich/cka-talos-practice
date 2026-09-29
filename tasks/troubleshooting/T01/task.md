# T01 — Recover the image pipeline

| Field | Value |
|---|---|
| Task ID | `T01` |
| CKA pillar | `troubleshooting` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The owned `sable-view` Deployment in the configured lab namespace is stuck on a nonexistent image tag. The selector `app=sable-view` and the container name `web` are already seeded.

## Required outcome

Inspect the rollout and Pod events. Restore the `web` container to `nginx:1.27-alpine` without replacing the Deployment or changing its selector. Confirm the template has that exact image and its one replica is updated and Available.

## Safety boundary

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.

## Validation

```bash
./tasks/troubleshooting/T01/score.sh
./tasks/troubleshooting/T01/score.sh --json
```

The two criteria are checked independently. Hints and answers remain outside task prompts under `answers/`.

From any directory, run `./tasks/troubleshooting/T01/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
