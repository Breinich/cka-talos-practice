# N11 Tutorial: Model two service exposures without applying them

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**NodePort and ExternalName have different Service semantics.** Offline two owned Service docs in configured namespace. `estuary-node-demo`: type NodePort, selector `app: estuary-api`, port name `http`, port 8080, targetPort `http`, nodePort 30081. `estuary-alias-demo`: type ExternalName, `externalName: estuary.lab.invalid` (no selector/ports). Validate local/client dry-run only. Ownership labels apply; do not apply because NodePort could expose the homelab workload. Avoid giving ExternalName a ClusterIP selector or adding a public backend assumption.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
