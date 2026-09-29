# N04 Tutorial: Resolve a search-path incident offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Resolver search order plus ndots determines candidate names.** Read `resources/dns.json`: query is short `estuary-front`, source namespace is active namespace, ndots=5, search list starts `<ns>.svc.cluster.local`, and simulated IP mapping lists front `10.96.12.21`, port `10.96.12.22`. Since short name has fewer than five dots, resolver tries search suffix first; expected qualified name `estuary-front.<ns>.svc.cluster.local`, address front IP, other address port IP, reason `namespace-search`. Write fields query, qualifiedName, resolvedAddress, otherServiceAddress, reason into N04-dns.json. Verify addresses are copied from input, not live cluster DNS.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
