# N06 Tutorial: Draft the legacy entrypoint offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Ingress is an API object and needs a controller/class to route traffic; this one is migration YAML only.** Produce `networking.k8s.io/v1` Ingress `estuary-entry` in `$NS` with owner label, `spec.ingressClassName: offline-estuary`, one rule host `estuary.lab.invalid`, HTTP path `/v1`, `pathType: Prefix`, backend Service `estuary-front`, port number 8080. Validate YAML client-side; do not create IngressClass, DNS, controller, or apply. Check hostname, class, path type and backend fields exactly; a working route cannot be claimed without controller.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
