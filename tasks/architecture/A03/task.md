# A03 — Repair a restricted reader

| Field | Value |
|---|---|
| Task ID | `A03` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 3 |

## Scenario and objective

Setup seeds `relay-identity`, Role `relay-reader` with only `get` on Pods, and RoleBinding `relay-reader`. Inventory these three objects, then adjust the owned Role so that this identity can get, list and watch Pods, and cannot create, patch, delete, or access Secrets. Preserve the namespace-scoped binding and the exact subject. Verify effective authorization through impersonated `can-i` checks.

## Scope and constraints

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A03` (including Pod templates). Never commit `.lab/` or credentials.
