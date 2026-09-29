# A08 Tutorial: Promote a local overlay into the lab

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Kustomize overlays keep upstream base reusable.** Setup creates a working copy of base; make changes only to its overlay, not source base. The overlay must supply prefix-derived name, namespace, replica count and labels on both resource and Pod template.

Inspect `$LAB/A08-kustomize/overlay/kustomization.yaml` plus the copied base. Configure the overlay with the local base reference, namespace `$NS`, `namePrefix: <active-prefix>-`, `replicas` entry for the base Deployment set to 2, and `commonLabels`/patch so `cka-lab.io/owner=cka-talos-practice` appears on Deployment and Pod template. Render first: `kubectl kustomize "$LAB/A08-kustomize/overlay"`; apply only the rendered Deployment to `$NS` (or use `kubectl apply -k` on the overlay), then `kubectl -n "$NS" rollout status deployment/<prefix>-kustom-app`. Check names/labels and ready replicas; do not change base.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A08/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A08/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
