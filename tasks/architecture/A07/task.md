# A07 — Render a local release without installing it

| Field | Value |
|---|---|
| Task ID | `A07` |
| CKA pillar | `architecture` |
| Mode | `simulation` |
| Capability | `helm` |
| Points | 2 |

## Scenario and objective

The bundled chart `tasks/architecture/A07/resources/chart` defaults to one relay replica. With Helm available, generate a local render for release `harbor-relay` in the active namespace with two replicas, saving it at `.lab/A07/<namespace>/evidence/A07-rendered.yaml`. The resulting Deployment must carry the release-derived name, namespace, two replicas, and the bundled container image. Do not install the chart or apply this render.

## Scope and constraints

Local artifacts only; never apply cluster-scoped definitions or rendered components. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A07` (including Pod templates). Never commit `.lab/` or credentials.
