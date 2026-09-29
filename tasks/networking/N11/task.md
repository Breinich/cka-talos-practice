# N11 — Model two service exposures without applying them

| Field | Value |
|---|---|
| Task ID | `N11` |
| CKA pillar | `networking` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario

Write `.lab/N11/<namespace>/evidence/N11-services.yaml` with two owned Services in the configured namespace, then run a local/client dry-run only. `estuary-node-demo` models a NodePort for the API selector at Service port 8080, named HTTP target and nodePort 30081. `estuary-alias-demo` models an ExternalName alias to `estuary.lab.invalid`.

## Expected state

Outcome: both types, ownership/scope, and exact mapping are checked independently. Do not apply the manifests: a NodePort may expose a homelab workload, and this exercise does not provision an external endpoint.

## Safety boundary

Local artifact only under `.lab/N11/<namespace>/evidence/`; do not apply it or alter cluster/system resources. The validator reads it offline.

## Validation

```bash
./tasks/networking/N11/score.sh
./tasks/networking/N11/score.sh --json
```

Two independent criteria are scored without printing a solution. Solutions are not included in prompts.

From any directory, run `./tasks/networking/N11/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
