# A17 Tutorial: Assess one failure before expanding HA

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**HA quorum arithmetic depends on healthy members, not nominal membership.** Three etcd members require two for quorum. With two healthy, another failure loses quorum; adding a same-zone peer does not improve fault-domain resilience. The API endpoint appears in SANs.

Read `resources/ha.json`, calculate members=3, healthy=2, quorum=2, `survivesAnotherFailure=false`, `endpointInSANs=true`, candidate zone `west`. Record input endpoint/zone exactly; `membershipMutationAllowedNow=false` because one member unhealthy, and choose `restore-elm-health` before membership changes. Write specified schema into `$LAB/evidence/A17.json`, independently compare every value with JSON. Do not modify Talos config or membership.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
