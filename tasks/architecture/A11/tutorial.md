# A11 Tutorial: Decide whether restore is permitted

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**etcd quorum and restore authorization are distinct.** Three members require a majority of two; two healthy peers currently preserve quorum. A verified encrypted snapshot does not override the absent approved change window.

Read `resources/restore.json`; count true `healthy` entries (2), calculate quorum `floor(3/2)+1` (2), copy snapshot path exactly, and set `snapshotUsable` true, `restoreAllowedNow` false, `firstAction` to `investigate-member`. Write the required keys to `$LAB/evidence/A11.json`. Explain that investigation precedes restore approval. Check values against source JSON; do not run etcd restore/snapshot commands or edit Talos.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
