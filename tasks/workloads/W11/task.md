# W11 — Use probes and security context

| Field | Value |
|---|---|
| Task ID | `W11` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

An isolated HTTP responder `ember-guard` is absent. It must expose port 8080 without privilege escalation. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w11}`; use after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w11}".

## Task

Create an owned Pod using `busybox:1.36` with command `httpd -f -p 8080`, TCP readiness and liveness probes on 8080, container `runAsUser: 10001`, and `allowPrivilegeEscalation: false. Keep it running; avoid a privileged port.

## Expected state

The correct probes and security fields are on the container; the HTTP process is ready in a Running Pod.

## Scope and constraints

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W11` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.
