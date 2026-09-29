# N01 Tutorial: Repair the front door

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Service selectors create EndpointSlices; Service port and targetPort differ.** Inspect `estuary-api` Pod labels/ports, `estuary-front`, and its EndpointSlices: `kubectl -n "$NS" get deploy estuary-api --show-labels`; `kubectl -n "$NS" get svc estuary-front -o yaml`; `kubectl -n "$NS" get endpointslice -l kubernetes.io/service-name=estuary-front -o yaml`. Fix only selector to `app: estuary-api`, retain ClusterIP and port 8080 with named targetPort `http`. Apply/patch Service. Verify ready EndpointSlice address and port 80 while Service stays 8080. Do not point selector at catalog or edit controller-created EndpointSlice.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
