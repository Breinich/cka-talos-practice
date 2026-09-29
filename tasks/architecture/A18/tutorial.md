# A18 Tutorial: Render a component overlay offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Kustomize local bases must live below the overlay root.** The source Deployment `collector-agent` has one replica and no task ownership on its Pod template; use a copied local component.

Copy `resources/component.yaml` and `kustomization.yaml` into `$LAB/evidence/A18-overlay/`. Edit component namespace to `$NS`; overlay adds replicas=2 and owner label to Deployment and Pod template while preserving app selector and nginx:1.27-alpine. Render with `kubectl kustomize "$LAB/evidence/A18-overlay" > "$LAB/evidence/A18-component.yaml"`. Inspect rendered YAML and verify exactly two replicas, namespace, labels and unchanged selector/image. The scorer rebuilds overlay and compares semantic render. Never apply synthetic collector.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A18/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A18/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
