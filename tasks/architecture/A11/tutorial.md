# A11 Tutorial: Decide whether restore is permitted

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**etcd quorum and restore authorization are distinct.** Three members require a majority of two; two healthy peers currently preserve quorum. A verified encrypted snapshot does not override the absent approved change window.

Read `resources/restore.json`; count true `healthy` entries (2), calculate quorum `floor(3/2)+1` (2), copy snapshot path exactly, and set `snapshotUsable` true, `restoreAllowedNow` false, `firstAction` to `investigate-member`. Write the required keys to `$LAB/evidence/A11.json`. Explain that investigation precedes restore approval. Check values against source JSON; do not run etcd restore/snapshot commands or edit Talos.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A11/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A11/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
