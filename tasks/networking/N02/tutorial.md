# N02 Tutorial: Publish a headless peer list

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Headless Services publish Pod DNS records through EndpointSlices.** Inspect `estuary-api` selector labels and named HTTP port. Create owned Service `estuary-peers` with `clusterIP: None`, selector exactly `app: estuary-api`, and port `{name: http, port: 8080, targetPort: http}` in `$NS`. Apply manifest with owner/task labels. Verify `kubectl get svc estuary-peers -o yaml` shows clusterIP None, then inspect EndpointSlices labeled `kubernetes.io/service-name=estuary-peers`; ready addresses should reference API Pods and backend port 80. Do not copy Deployment’s containerPort 80 as Service port; task Service port is 8080.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
