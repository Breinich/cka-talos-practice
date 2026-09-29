# N03 — Recover a missing catalog endpoint

| Field | Value |
|---|---|
| Task ID | `N03` |
| CKA pillar | `networking` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The `estuary-catalog` Service already exists but its EndpointSlice has no ready API address. Compare its selector with the running `estuary-api` Deployment; repair only `estuary-catalog`.

## Expected state

Outcome: the Service remains on port 8080 with its named backend port, selects the API workload, and its ready EndpointSlice contains an address and port 80. Do not edit the controller-generated EndpointSlice directly.

## Safety boundary

Work only in the configured lab namespace; label created resources `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=N03` (including Pod templates). Do not mutate nodes or system namespaces.

## Validation

```bash
./tasks/networking/N03/score.sh
./tasks/networking/N03/score.sh --json
```

Two independent criteria are scored without printing a solution. Solutions are not included in prompts.

From any directory, run `./tasks/networking/N03/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
