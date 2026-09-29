# S04 Tutorial: Inventory storage without mutating it

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**StorageClass and CSIDriver are cluster-scoped inventories; capture complete snapshots, including empty arrays.** Query `kubectl get storageclass -o json` and `kubectl get csidriver -o json`. For each class sort by metadata.name and record name, provisioner, reclaimPolicy, volumeBindingMode, allowVolumeExpansion (false if missing), and `isDefault` only if annotation equals literal string `true`. Sort driver names. Write exactly `{ "classes": [...], "drivers": [...] }` to S04.json. Re-read and compare full list; do not include credentials or edit cluster-wide storage configuration.

## Task-scoped workflow: read-only observations

Use only read operations for the named API endpoint/node and write evidence locally. Do not create a namespace or change any Kubernetes resource. Derive evidence from fresh observations; no object edit or cleanup is needed. If a Talos API is unavailable, report the supported UNSUPPORTED result rather than attempting another access path.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
