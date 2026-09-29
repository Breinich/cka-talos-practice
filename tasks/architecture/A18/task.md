# A18 — Render a component overlay offline

| Field | Value |
|---|---|
| Task ID | `A18` |
| CKA pillar | `architecture` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

The synthetic collector at `tasks/architecture/A18/resources/component.yaml` is not a real cluster service. Copy the bundled component into `.lab/A18/<namespace>/evidence/A18-overlay` and create a Kustomize overlay there (Kustomize does not allow a base outside its load root); render `.lab/A18/<namespace>/evidence/A18-component.yaml` locally. Adjust to two replicas and the active namespace, preserving the owner label on Deployment and Pod template.

## Scope and constraints

Local artifacts only; never apply cluster-scoped definitions or rendered components. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A18` (including Pod templates). Never commit `.lab/` or credentials.
