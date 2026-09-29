# A06 — Classify an uninstalled API extension

| Field | Value |
|---|---|
| Task ID | `A06` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

`tasks/architecture/A06/resources/crd.yaml` is a synthetic API definition, not installed on the cluster. Inspect it offline. Write `.lab/A06/<namespace>/evidence/A06.json` with `group`, `scope`, `plural`, `servedVersions` (array), and `storageVersion` matching that definition. Determine which endpoint a namespaced client would discover and put it in `resourcePath`, using the active namespace. Never apply this CRD.

## Scope and constraints

Local evidence only; do not create cluster objects. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A06` (including Pod templates). Never commit `.lab/` or credentials.
