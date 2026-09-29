# W07 Tutorial: Use ConfigMap and Secret projections

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**ConfigMaps and Secrets should be referenced, not embedded in a Pod manifest.** Create owned ConfigMap `ember-settings` with `MODE=audit`, Opaque Secret `ember-token` with `TOKEN=dummy`, and Pod `ember-consumer` using `busybox:1.36`, `sh -c "sleep 7d"`. Define env entries with `valueFrom.configMapKeyRef` (`ember-settings`, key MODE) and `valueFrom.secretKeyRef` (`ember-token`, key TOKEN). Put ownership labels on objects and Pod. Verify references and Ready state using `kubectl -n "$NS" get pod ember-consumer -o yaml`; inspect ConfigMap keys only and never print/decode Secret contents. Avoid literal env values because that defeats reference semantics.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
