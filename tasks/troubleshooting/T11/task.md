# T11 — Correlate control-plane signals

| Field | Value |
|---|---|
| Task ID | `T11` |
| CKA pillar | `troubleshooting` |
| Mode | `read-only` |
| Capability | `talosctl` |
| Points | 3 |

## Scenario

Read-only **Talos** investigation on a control-plane node. API readiness, static Pod health and etcd membership are distinct signals; do not modify etcd, manifests, certificates or services.

## Required outcome

Select a control-plane node. Query `/readyz`; inspect its `kube-apiserver`, `kube-scheduler`, `kube-controller-manager` static Pods in `kube-system` and the same node’s etcd service state and etcd member inventory. Record `.lab/T11/<namespace>/evidence/T11.json` with `controlPlaneNode`, `apiReady` (boolean), `componentPods` (map from each of those three component labels to its running Pod name), `services` (`etcd` = `Running`), and `memberCount` (number of returned member objects).

## Scope and constraints

Read-only; no node, control-plane or Talos machine changes.
