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

Select a control-plane node. Query `/readyz`; inspect its `kube-apiserver`, `kube-scheduler`, `kube-controller-manager` static Pods in `kube-system` and the same node’s `talosctl -n <node> service etcd` and `talosctl -n <node> get members -o json`. Record `.lab/T11/<namespace>/evidence/T11.json` with `controlPlaneNode`, `apiReady` (boolean), `componentPods` (map from each of those three component labels to its running Pod name), `services` (`etcd` = `Running`), and `memberCount` (number of returned member objects). The two checks cover API/component readiness and etcd service/membership separately. If Talos access is absent, expect UNSUPPORTED.

## Safety boundary

Read-only; no node, control-plane or Talos machine changes.

## Validation

```bash
./tasks/troubleshooting/T11/score.sh
./tasks/troubleshooting/T11/score.sh --json
```

The two criteria are checked independently. Hints and answers remain outside task prompts under `answers/`.

From any directory, run `./tasks/troubleshooting/T11/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
