# A10 Tutorial: Triage Talos services without repair

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Talos service inventory is read-only.** A service being stopped is an observation, not permission to restart it.

Choose a visible control-plane node from `kubectl get nodes`; when Talos access exists, run `talosctl health -n "$NODE"` and `talosctl services -n "$NODE"`. Record node, health status, kubelet/containerd running-or-stopped states and one literal service status line in `$LAB/evidence/A10.json`. Verify the chosen line is actually from that node’s output and service booleans/strings agree with observed state. Never save talosconfig, run `service restart`, reset or apply-config. If no Talos endpoint/access, record the supported unsupported result rather than guessing.

## Task-scoped workflow: read-only observations

Use only read operations for the named API endpoint/node and write evidence locally. Do not create a namespace or change any Kubernetes resource. Derive evidence from fresh observations; no object edit or cleanup is needed. If a Talos API is unavailable, report the supported UNSUPPORTED result rather than attempting another access path.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
