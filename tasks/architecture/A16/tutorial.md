# A16 Tutorial: Model an operator install offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Operator architecture is modeled declaratively, not installed.** Read the synthetic CRD first: group `telemetry.example.test`, plural `signals`, kind `Signal`, namespace scope, served v1alpha1/v1, storage v1. Build six YAML documents in `$LAB/evidence/A16-operator.yaml`: compatible CRD, `Signal` named `harbor-signal`, one-replica `signal-operator` Deployment using busybox:1.36, same-named ServiceAccount, Role restricted to get/list/watch on `signals.telemetry.example.test`, and RoleBinding to that account. Put namespaced objects in `$NS`; owner label on every object and CRD prefix label on CRD. Validate locally with `kubectl create --dry-run=client -f ... -o yaml`; never apply/install. Ensure Role has no wildcard permissions.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
