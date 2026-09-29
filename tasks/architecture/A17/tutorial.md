# A17 Tutorial: Assess one failure before expanding HA

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**HA quorum arithmetic depends on healthy members, not nominal membership.** Three etcd members require two for quorum. With two healthy, another failure loses quorum; adding a same-zone peer does not improve fault-domain resilience. The API endpoint appears in SANs.

Read `resources/ha.json`, calculate members=3, healthy=2, quorum=2, `survivesAnotherFailure=false`, `endpointInSANs=true`, candidate zone `west`. Record input endpoint/zone exactly; `membershipMutationAllowedNow=false` because one member unhealthy, and choose `restore-elm-health` before membership changes. Write specified schema into `$LAB/evidence/A17.json`, independently compare every value with JSON. Do not modify Talos config or membership.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A17/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A17/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
