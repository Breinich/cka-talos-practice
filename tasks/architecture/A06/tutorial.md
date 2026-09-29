# A06 Tutorial: Classify an uninstalled API extension

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**CRD discovery paths.** A CustomResourceDefinition’s group, scope, plural and versions define its REST path. Read `resources/crd.yaml`; do not install it. The definition says group `telemetry.example.test`, Namespaced scope, plural `signals`, served versions `v1alpha1` and `v1`, storage version `v1`.

Write `.lab/A06/$NS/evidence/A06.json` with those values and `resourcePath: "/apis/telemetry.example.test/v1/namespaces/$NS/signals"` (use the endpoint corresponding to the chosen served version consistently; here use storage `v1`). Verify array order/content and exact namespace placement. A namespaced resource path includes both `/namespaces/<ns>/` and the plural; do not use singular `signal`, `/api` core-group prefix, or claim the API exists live.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A06/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A06/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
