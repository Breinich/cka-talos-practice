# N01 — Repair the front door

| Field | Value |
|---|---|
| Task ID | `N01` |
| CKA pillar | `networking` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The estuary API Deployment is already running in the lab namespace. `estuary-front` is present on port 8080 but has no usable backends. Inspect the Deployment labels, Service selector, and EndpointSlices, then repair only this Service.

## Expected state

Outcome: its owned ClusterIP Service selects `estuary-api`, exposes port 8080 to the named HTTP container port; a ready EndpointSlice advertises port 80 and an address. Leave `estuary-catalog` and `estuary-port` for their own exercises.

## Safety boundary

Work only in the configured lab namespace; label created resources `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=N01` (including Pod templates). Do not mutate nodes or system namespaces.

## Validation

```bash
./tasks/networking/N01/score.sh
./tasks/networking/N01/score.sh --json
```

Two independent criteria are scored without printing a solution. Solutions are not included in prompts.

From any directory, run `./tasks/networking/N01/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
