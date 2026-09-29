# A02 — Scope a temporary client identity

| Field | Value |
|---|---|
| Task ID | `A02` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 3 |

## Scenario and objective

Setup supplies ServiceAccount `relay-identity` and a namespaced Role permitting Pod get. Operations need a separate kubeconfig at `.lab/A02/<namespace>/evidence/A02.kubeconfig` for this identity only. Obtain a short-lived token for this identity; include only the current cluster server/CA, the token identity and one context. Check that it can get Pod `toolbox` but cannot delete Pods. Keep the file mode 0600; do not copy an admin credential. Token expiration means this task must be scored shortly after creation.

## Scope and constraints

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A02` (including Pod templates). Never commit `.lab/` or credentials.
