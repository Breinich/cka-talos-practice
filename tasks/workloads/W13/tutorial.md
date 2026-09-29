# W13 Tutorial: Protect availability during disruptions

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**PodDisruptionBudget constrains voluntary evictions, not controller availability itself.** Confirm seeded `ember-api` has two Ready replicas. Create owned PDB `ember-api` selecting exactly `app=ember-api`, `minAvailable: 1` in `$NS`, with required ownership label. Apply manifest, then `kubectl -n "$NS" get pdb ember-api -o yaml`; verify expectedPods=2, currentHealthy=2, disruptionsAllowed at least 1. PDB selector must match Deployment Pod labels and use a selector map, not a Deployment name. Do not drain/evict a node to test it.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W13/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W13/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
