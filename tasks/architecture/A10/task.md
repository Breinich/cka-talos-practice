# A10 — Triage Talos services without repair

| Field | Value |
|---|---|
| Task ID | `A10` |
| CKA pillar | `architecture` |
| Mode | `read-only` |
| Capability | `talosctl` |
| Points | 2 |

## Scenario and objective

If the Talos API is available, inspect health and service status read-only for an existing control-plane machine. In `.lab/A10/<namespace>/evidence/A10.json` record `node`, `health` (healthy/unhealthy), `kubelet` and `containerd` (running/stopped), and `observation` (a literal status line from the service inventory). Never save talosconfig or issue service restarts, reset, apply-config or upgrades.

## Scope and constraints

Observation only; do not change cluster resources, certificates, host configuration or services. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A10` (including Pod templates). Never commit `.lab/` or credentials.
