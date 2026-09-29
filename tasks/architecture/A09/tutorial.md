# A09 Tutorial: Locate control-plane services without host access

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Static Pod mirrors are an API-visible view, not host access.** Inventory only what the API exposes; Talos may not publish etcd mirrors.

Use `kubectl get pods -n kube-system -o wide` and `kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'` for the endpoint. Classify complete Pod-name arrays by component substring (`kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, `etcd`) and collect unique `.spec.nodeName` values from the listing. Write all four arrays (empty only if genuinely absent), endpoint, observedNodes and a note explaining invisible mirrors to `$LAB/evidence/A09.json`. Verify no duplicates and that arrays reflect the whole listing. Never SSH to a node or restart a static Pod.

## Task-scoped workflow: read-only observations

Use only read operations for the named API endpoint/node and write evidence locally. Do not create a namespace or change any Kubernetes resource. Derive evidence from fresh observations; no object edit or cleanup is needed. If a Talos API is unavailable, report the supported UNSUPPORTED result rather than attempting another access path.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
