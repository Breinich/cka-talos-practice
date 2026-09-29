# N07 Tutorial: Translate the entrypoint into header routing

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**HTTPRoute rule ordering matters: header-specific match must precede fallback path match.** Offline manifest `gateway.networking.k8s.io/v1` HTTPRoute `estuary-route`, namespace `$NS`, owned label, parentRef name `estuary-gateway`, sectionName `http`, hostname `estuary.lab.invalid`. First rule matches path prefix `/v1` AND exact header `x-estuary-tier: canary` to `estuary-port:8080`; second matches `/v1` to `estuary-front:8080`. Use distinct rule entries in that order. Check refs and backend port refs. These CRDs/Gateway are not installed: render/parse only; no Accepted/Programmed claim and never apply.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
