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

Identify a node running `toolbox` and inspect its Kubernetes `containerRuntimeVersion` and Pod `runtimeClassName` (empty string if unset). On that same node inspect the kubelet and containerd Talos service states. Save `.lab/T10/<namespace>/evidence/T10.json` with `node`, `runtimeVersion`, `podRuntimeClass`, `kubeletService`, `containerdService`; service values must be `Running`.

## Scope and constraints

Only setup's namespaced Pod and evidence may change; inspect node and Talos state read-only. No node, control-plane or Talos machine changes. Teardown removes only this task's verified namespace.
