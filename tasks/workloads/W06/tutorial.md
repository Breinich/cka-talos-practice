# W06 Tutorial: Create a StatefulSet with stable identity

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**StatefulSet ordinal identity is provided by its headless governing Service.** Inspect `ember-ledger` and `ember-ledger` StatefulSet, then scale only the StatefulSet to two replicas: `kubectl -n "$NS" scale statefulset/ember-ledger --replicas=2`. Preserve `serviceName: ember-ledger`, selector `app=ember-ledger`, and headless Service (`clusterIP: None`). Check `kubectl -n "$NS" get sts,pods -o wide`: replicas 2/2 Ready, Pods `ember-ledger-0` and `-1`, ordinal 2 gone. No PVCs are in this exercise; do not create/delete storage claims or alter the Service.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W06/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W06/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
