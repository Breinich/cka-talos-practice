# T07 Tutorial: Rank eviction candidates offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**QoS class and priority influence eviction ranking under resource pressure.** Offline: inspect `resources/qos.yaml`. BestEffort `probe-scratch` has no requests/limits; Burstable `archive-index` requests below limits; `edge-cache` assumed above memory request. Make only archive-index Guaranteed by setting requests and limits equal: CPU 50m, memory 32Mi. Given equal priority + memory pressure + cache above request, expected order: BestEffort scratch first, then Burstable cache, Guaranteed archive-index last. Save edited three-doc yaml and JSON keys first/second/last plus pressure=memory and equalPriority=true. Do not apply or induce pressure.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
