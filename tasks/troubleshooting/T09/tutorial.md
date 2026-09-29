# T09 Tutorial: Build a node pressure inventory

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Node conditions, taints and allocatable are different from raw capacity.** Read `kubectl get nodes` and choose one real node, then `kubectl get node "$NODE" -o json`. Build T09.json with exact status strings for Ready/MemoryPressure/DiskPressure/PIDPressure, spec taints or [], and `capacity`/`allocatable` each containing exact CPU and memory quantity strings. Verify no unit normalization/rounding, preserve nil taints as empty array, and compare against same node fresh read. Read-only only; do not patch node or induce pressure.

## Task-scoped workflow: read-only observations

Use only read operations for the named API endpoint/node and write evidence locally. Do not create a namespace or change any Kubernetes resource. Derive evidence from fresh observations; no object edit or cleanup is needed. If a Talos API is unavailable, report the supported UNSUPPORTED result rather than attempting another access path.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
