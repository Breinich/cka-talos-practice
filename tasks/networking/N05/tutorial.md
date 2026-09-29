# N05 Tutorial: Design isolated client egress offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**NetworkPolicy egress isolation is additive: selecting a Pod isolates it, then allow rules union together.** Offline only. Write two policies to N05-policy.yaml. Both `podSelector.matchLabels` must include `app: toolbox` and owner label; `policyTypes: [Egress]`. Deny policy selects the client and has no egress rules. Allow policy contains exactly two rules: UDP port 53 to namespaceSelector `kubernetes.io/metadata.name: kube-system`; TCP port 80 to same-namespace Pods `app: estuary-api` AND owner label (one `to` peer with podSelector). Both owned and namespace `$NS`. The core `spec` structure is:

```yaml
# deny policy
spec:
  podSelector:
    matchLabels: {app: toolbox, cka-lab.io/owner: cka-talos-practice}
  policyTypes: [Egress]
  # no egress list: all selected-Pod egress denied
---
# allow policy
spec:
  podSelector:
    matchLabels: {app: toolbox, cka-lab.io/owner: cka-talos-practice}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: kube-system}
    ports: [{protocol: UDP, port: 53}]
  - to:
    - podSelector:
        matchLabels: {app: estuary-api, cka-lab.io/owner: cka-talos-practice}
    ports: [{protocol: TCP, port: 80}]
```

Wrap each spec in its own `networking.k8s.io/v1` NetworkPolicy document with exact names and namespace. Confirm DNS UDP/53 and API TCP/80 only; no blanket allow, no TCP DNS substitution, and no apply since enforcement is not modeled.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
