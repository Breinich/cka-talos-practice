# A08 — Promote a local overlay into the lab

| Field | Value |
|---|---|
| Task ID | `A08` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

Setup copies `tasks/architecture/A08/resources/kustomize/base` (one replica, no namespace or ownership marker) to `.lab/A08/<namespace>/A08-kustomize/`. Complete that instance's `.lab/A08/<namespace>/A08-kustomize/overlay/kustomization.yaml` so the render produces Deployment `<prefix>-kustom-app`, in the active namespace, with two replicas and the owner label on both object and Pod template. Apply only that Deployment to the owned namespace and verify its rollout. Do not touch the base.

## Scope and constraints

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A08` (including Pod templates). Never commit `.lab/` or credentials.
