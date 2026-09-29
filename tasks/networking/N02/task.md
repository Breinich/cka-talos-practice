# N02 — Publish a headless peer list

| Field | Value |
|---|---|
| Task ID | `N02` |
| CKA pillar | `networking` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

`estuary-api` already has a ready replica and a named HTTP port. Add an owned headless `estuary-peers` Service for that workload, with Service port 8080. Discover its labels and ports before creating the Service.

## Expected state

Outcome: the Service has `clusterIP: None`, selects exactly the API Pods and has a ready EndpointSlice with port 80. Inspect `kubectl get endpointslice -n "$CKA_LAB_NAMESPACE" -l kubernetes.io/service-name=estuary-peers` (use the setup namespace if unset).

## Safety boundary

Work only in the configured lab namespace; label created resources `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=N02` (including Pod templates). Do not mutate nodes or system namespaces.

## Validation

```bash
./tasks/networking/N02/score.sh
./tasks/networking/N02/score.sh --json
```

Two independent criteria are scored without printing a solution. Solutions are not included in prompts.

From any directory, run `./tasks/networking/N02/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
