# W13 Tutorial: Protect availability during disruptions

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**PodDisruptionBudget constrains voluntary evictions, not controller availability itself.** Confirm seeded `ember-api` has two Ready replicas. Create owned PDB `ember-api` selecting exactly `app=ember-api`, `minAvailable: 1` in `$NS`, with required ownership label. Apply manifest, then `kubectl -n "$NS" get pdb ember-api -o yaml`; verify expectedPods=2, currentHealthy=2, disruptionsAllowed at least 1. PDB selector must match Deployment Pod labels and use a selector map, not a Deployment name. Do not drain/evict a node to test it.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
