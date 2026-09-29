# N08 — Repair an incorrect backend port

| Field | Value |
|---|---|
| Task ID | `N08` |
| CKA pillar | `networking` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The owned `estuary-port` Service already selects ready `estuary-api` Pods and listens on 8080, but its backend port does not reach the HTTP container. Compare Deployment ports, Service targetPort and EndpointSlice ports; repair this Service without changing the Deployment.

## Expected state

Outcome: the Service points to the named HTTP container port and a ready EndpointSlice advertises port 80/address. An EndpointSlice address alone does not prove that the targetPort was correct.

## Safety boundary

Work only in the configured lab namespace; label created resources `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=N08` (including Pod templates). Do not mutate nodes or system namespaces.

## Validation

```bash
./tasks/networking/N08/score.sh
./tasks/networking/N08/score.sh --json
```

Two independent criteria are scored without printing a solution. Solutions are not included in prompts.

From any directory, run `./tasks/networking/N08/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
