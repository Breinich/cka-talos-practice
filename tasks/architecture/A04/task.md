# A04 — Run a non-API consumer without a token

| Field | Value |
|---|---|
| Task ID | `A04` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

The seeded `relay-identity` is restricted but an offline relay Pod does not need Kubernetes API access. Create owned Pod `relay-consumer` in the lab namespace using that identity, image `busybox:1.36`, and a long-running sleep command. Disable automatic token mounting on the Pod. Verify its effective ServiceAccount and Running state; do not alter the seeded ServiceAccount or bind additional privileges.

## Scope and constraints

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A04` (including Pod templates). Never commit `.lab/` or credentials.
