# N05 — Design isolated client egress offline

| Field | Value |
|---|---|
| Task ID | `N05` |
| CKA pillar | `networking` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 3 |

## Scenario

The `toolbox` client must be isolated for egress, while still resolving DNS in `kube-system` and reaching the estuary API on TCP/80. No live policy-enforcement capability is assumed. Write **only** `.lab/N05/<namespace>/evidence/N05-policy.yaml` with owned namespaced NetworkPolicies `estuary-egress-deny` and `estuary-egress-allow` for the owned `app=toolbox` Pod (scope selectors by both app and owner labels). Do not apply the file.

## Expected state

Outcome: deny egress for that client without isolating unrelated Pods; permit only UDP/53 to namespace `kube-system` and TCP/80 to owned Pods labeled `app=estuary-api` in the same namespace.

## Scope and constraints

Local artifact only under `.lab/N05/<namespace>/evidence/`; do not apply it or alter cluster/system resources. The validator reads it offline.
