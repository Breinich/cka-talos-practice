# S05 Tutorial: Grow a bound disposable claim

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Expansion increases requested capacity; storage backends report completion asynchronously.** Gate on `EXPANDABLE=true` and approved disposable class, else SKIP. Create `lighthouse-live` PVC at 64Mi and reader Pod first, write receipt. Patch only that claim request to 128Mi (for example `kubectl -n "$NS" patch pvc lighthouse-live --type merge -p '{"spec":{"resources":{"requests":{"storage":"128Mi"}}}}'`). Wait until request and status.capacity both 128Mi and PVC remains Bound; leave Pod Ready and check receipt persisted. Never shrink, edit StorageClass/PV, or invoke teardown until manual data cleanup/review.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/S05/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/storage/S05/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
