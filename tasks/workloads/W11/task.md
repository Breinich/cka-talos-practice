# W11 — Use probes and security context

| Field | Value |
|---|---|
| Task ID | `W11` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

An isolated HTTP responder `ember-guard` is absent. It must expose port 8080 without privilege escalation. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w11}`; use `kubectl -n "$NAMESPACE"` after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w11}"`.

## Task

Create an owned Pod using `busybox:1.36` with command `httpd -f -p 8080`, TCP readiness and liveness probes on 8080, container `runAsUser: 10001`, and `allowPrivilegeEscalation: false`. Keep it running; avoid a privileged port.

## Expected state

The correct probes and security fields are on the container; the HTTP process is ready in a Running Pod.

## Safety boundary

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W11` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.

## Validation

```bash
./tasks/workloads/W11/score.sh
./tasks/workloads/W11/score.sh --json
```

Two independent end-state criteria are scored. The validator does not repair resources or publish a solution.

From any directory, run `./tasks/workloads/W11/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
