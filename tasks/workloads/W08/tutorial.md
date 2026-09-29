# W08 Tutorial: Apply node affinity and pod anti-affinity

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Required affinity is a hard scheduling constraint; anti-affinity spreads matching replicas by topology domain.** First inspect `kubectl get nodes --show-labels` and Ready/taint state. Patch `ember-placement` template with required node affinity `nodeSelectorTerms` matching key `node-role.kubernetes.io/worker`, operator `Exists`. Add requiredDuringSchedulingIgnoredDuringExecution pod anti-affinity with selector `app=ember-placement` and topologyKey `kubernetes.io/hostname`; retain replicas=2. Wait and check each Ready Pod’s node is a distinct eligible worker. Required, not preferred, is scored. If fewer than two eligible workers, stop and accept SKIP; never relabel nodes.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W08/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W08/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
