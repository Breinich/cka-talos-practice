# A09 — Locate control-plane services without host access

| Field | Value |
|---|---|
| Task ID | `A09` |
| CKA pillar | `architecture` |
| Mode | `read-only` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

This Talos lab may expose static Pod mirrors in `kube-system`, but topology varies. Inspect the component Pod inventory and API server endpoint. In `.lab/A09/<namespace>/evidence/A09.json` record `apiServerPods`, `schedulerPods`, `controllerPods`, `etcdPods` as the complete arrays of matching static Pod mirror names (use empty arrays only when no matches are visible), plus `apiServerEndpoint` and `observedNodes` as all distinct node names in that Pod listing. Empty component arrays are allowed when Talos does not expose those mirrors; explain visibility limits in `notes`. Do not access nodes or restart components.

## Scope and constraints

Observation only; do not change cluster resources, certificates, host configuration or services. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A09` (including Pod templates). Never commit `.lab/` or credentials.
