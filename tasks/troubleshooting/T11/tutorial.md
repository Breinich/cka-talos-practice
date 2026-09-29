# T11 Tutorial: Correlate control-plane signals

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**API readiness, static Pod Running, etcd service, and membership are separate signals.** Select control-plane node, query API `/readyz`, inspect kube-system Pods for component labels kube-apiserver/scheduler/controller-manager and node placement. Use `talosctl -n "$NODE" service etcd` and `talosctl -n "$NODE" get members -o json` read-only. Record controlPlaneNode, apiReady boolean, componentPods map to running Pod names, services.etcd=Running, memberCount = number of returned member objects. Verify exactly those components on chosen node; API not ready or missing mirrors should not be guessed. If Talos API unavailable, UNSUPPORTED. Never touch etcd/manifests/certs/services.

## Task-scoped workflow: read-only observations

Use only read operations for the named API endpoint/node and write evidence locally. Do not create a namespace or change any Kubernetes resource. Derive evidence from fresh observations; no object edit or cleanup is needed. If a Talos API is unavailable, report the supported UNSUPPORTED result rather than attempting another access path.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
