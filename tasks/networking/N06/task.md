# N06 — Draft the legacy entrypoint offline

| Field | Value |
|---|---|
| Task ID | `N06` |
| CKA pillar | `networking` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario

A synthetic legacy endpoint for the estuary API needs hostname `estuary.lab.invalid` and Prefix path `/v1` directed to `estuary-front:8080`. Create `.lab/N06/<namespace>/evidence/N06-ingress.yaml` as an owned namespaced Ingress called `estuary-entry`, with `ingressClassName: offline-estuary`. It is a migration input, not an installed controller.

## Expected state

Outcome: the hostname/class and the path/backend each match exactly. Do not apply this manifest or create an IngressClass; no public DNS or ingress controller is required.

## Safety boundary

Local artifact only under `.lab/N06/<namespace>/evidence/`; do not apply it or alter cluster/system resources. The validator reads it offline.

## Validation

```bash
./tasks/networking/N06/score.sh
./tasks/networking/N06/score.sh --json
```

Two independent criteria are scored without printing a solution. Solutions are not included in prompts.

From any directory, run `./tasks/networking/N06/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
