# A01 — Read the live discovery surface

| Field | Value |
|---|---|
| Task ID | `A01` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

The dispatch team needs to know whether Pod and Role are namespaced before applying a scoped change. The current context is the configured Talos lab; no API objects need changing. Inspect the API version, namespaced-resource discovery and the RBAC API group. Save `.lab/A01/<namespace>/evidence/A01.json` with `serverVersion` (the server gitVersion), `podNamespaced` (boolean), and `roleGroup` (`rbac.authorization.k8s.io`). Do not save credentials or the full kubeconfig.

## Scope and constraints

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A01` (including Pod templates). Never commit `.lab/` or credentials.
