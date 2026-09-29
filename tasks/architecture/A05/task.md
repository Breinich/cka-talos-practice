# A05 — Check both sides of the permission boundary

| Field | Value |
|---|---|
| Task ID | `A05` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

After repairing A03, the relay identity must list Pods but must not delete Pods. Investigate with impersonating `system:serviceaccount:<namespace>:relay-identity` in the active namespace.

## Scope and constraints

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A05` (including Pod templates). Never commit `.lab/` or credentials.
