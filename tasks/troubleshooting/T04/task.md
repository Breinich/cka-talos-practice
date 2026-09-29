# T04 — Reconnect a Service to its backends

| Field | Value |
|---|---|
| Task ID | `T04` |
| CKA pillar | `troubleshooting` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The `sable-route` Service exposes port 80 to port 80, but its selector misses the existing `web` Deployment.

## Required outcome

Inspect the Service and EndpointSlices. Correct its selector to `app=web` without changing the ports; show a ready address in an EndpointSlice for `sable-route`. Do not edit the shared `web` workload.

## Safety boundary

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.

## Validation

```bash
./tasks/troubleshooting/T04/score.sh
./tasks/troubleshooting/T04/score.sh --json
```

The two criteria are checked independently. Hints and answers remain outside task prompts under `answers/`.

From any directory, run `./tasks/troubleshooting/T04/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
