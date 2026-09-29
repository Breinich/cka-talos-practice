# A06 Tutorial: Classify an uninstalled API extension

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**CRD discovery paths.** A CustomResourceDefinition’s group, scope, plural and versions define its REST path. Read `resources/crd.yaml`; do not install it. The definition says group `telemetry.example.test`, Namespaced scope, plural `signals`, served versions `v1alpha1` and `v1`, storage version `v1`.

Write `.lab/A06/$NS/evidence/A06.json` with those values and `resourcePath: "/apis/telemetry.example.test/v1/namespaces/$NS/signals"` (use the endpoint corresponding to the chosen served version consistently; here use storage `v1`). Verify array order/content and exact namespace placement. A namespaced resource path includes both `/namespaces/<ns>/` and the plural; do not use singular `signal`, `/api` core-group prefix, or claim the API exists live.

## Task-scoped workflow: offline CRD analysis

Despite its metadata capability, A06 is an offline resource-definition analysis: read `resources/crd.yaml`, write local JSON, and do not apply/install its CRD or mutate any live resource. No cluster discovery or controller status is required.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
