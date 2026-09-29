# A18 Tutorial: Render a component overlay offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Kustomize local bases must live below the overlay root.** The source Deployment `collector-agent` has one replica and no task ownership on its Pod template; use a copied local component.

Copy `resources/component.yaml` and `kustomization.yaml` into `$LAB/evidence/A18-overlay/`. Edit component namespace to `$NS`; overlay adds replicas=2 and owner label to Deployment and Pod template while preserving app selector and nginx:1.27-alpine. Render with `kubectl kustomize "$LAB/evidence/A18-overlay" > "$LAB/evidence/A18-component.yaml"`. Inspect rendered YAML and verify exactly two replicas, namespace, labels and unchanged selector/image. The scorer rebuilds overlay and compares semantic render. Never apply synthetic collector.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
