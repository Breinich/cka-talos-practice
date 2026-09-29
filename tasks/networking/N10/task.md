# N10 — Check the repaired service through a local tunnel

| Field | Value |
|---|---|
| Task ID | `N10` |
| CKA pillar | `networking` |
| Mode | `live` |
| Capability | `core` |
| Points | 1 |

## Scenario

This task seeds its own repaired `estuary-front` and API workload; independently of N01, port-forward its Service from local port 18080 to Service port 8080, fetch `http://127.0.0.1:18080/`, then stop the forward. No public listener or NodePort is needed.

## Expected state

Write `.lab/N10/<namespace>/evidence/N10-forward.json` containing `namespace`, `service`, `localPort`, `remotePort`, `httpStatus` and the captured `body` (no credentials). The scorer checks tunnel parameters and the expected HTTP response together with the live ready endpoint; a recording alone cannot prove that a tunnel actually ran, so retain your terminal transcript for human review.

## Safety boundary

Work only in the configured lab namespace; label created resources `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=N10` (including Pod templates). Do not mutate nodes or system namespaces.

## Validation

```bash
./tasks/networking/N10/score.sh
./tasks/networking/N10/score.sh --json
```

Two independent criteria are scored without printing a solution. Solutions are not included in prompts.

From any directory, run `./tasks/networking/N10/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
