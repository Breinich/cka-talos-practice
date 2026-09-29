# T10 — Trace kubelet to its runtime

| Field | Value |
|---|---|
| Task ID | `T10` |
| CKA pillar | `troubleshooting` |
| Mode | `live` |
| Capability | `talosctl` |
| Points | 2 |

## Scenario

Setup creates an owned `toolbox` Pod in **this task's isolated namespace**. Investigate its Talos node and runtime read-only; no host SSH, `crictl` install, restarts, or configuration edits are allowed. The lab Pod is disposable and no other task's namespace is needed.

## Required outcome

Identify a node running `toolbox` and inspect its Kubernetes `containerRuntimeVersion` and Pod `runtimeClassName` (empty string if unset). On that same node run `talosctl -n <node> service kubelet` and `talosctl -n <node> service containerd`; inspect their state. Save `.lab/T10/<namespace>/evidence/T10.json` with `node`, `runtimeVersion`, `podRuntimeClass`, `kubeletService`, `containerdService`; service values must be `Running`. The validator compares the runtime to the node and queries both Talos services live. If Talos API access is absent, expect UNSUPPORTED.

## Safety boundary

Only setup's namespaced Pod and evidence may change; inspect node and Talos state read-only. No node, control-plane or Talos machine changes. Teardown removes only this task's verified namespace.

## Validation

```bash
./tasks/troubleshooting/T10/score.sh
./tasks/troubleshooting/T10/score.sh --json
```

The two criteria are checked independently. Hints and answers remain outside task prompts under `answers/`.

From any directory, run `./tasks/troubleshooting/T10/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
