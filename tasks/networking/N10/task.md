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

Write `.lab/N10/<namespace>/evidence/N10-forward.json` containing `namespace`, `service`, `localPort`, `remotePort`, `httpStatus` and the captured `body` (no credentials).

## Scope and constraints

Work only in the configured lab namespace; label created resources `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=N10` (including Pod templates). Do not mutate nodes or system namespaces.
