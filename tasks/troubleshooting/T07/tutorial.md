# T07 Tutorial: Rank eviction candidates offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**QoS class and priority influence eviction ranking under resource pressure.** Offline: inspect `resources/qos.yaml`. BestEffort `probe-scratch` has no requests/limits; Burstable `archive-index` requests below limits; `edge-cache` assumed above memory request. Make only archive-index Guaranteed by setting requests and limits equal: CPU 50m, memory 32Mi. Given equal priority + memory pressure + cache above request, expected order: BestEffort scratch first, then Burstable cache, Guaranteed archive-index last. Save edited three-doc yaml and JSON keys first/second/last plus pressure=memory and equalPriority=true. Do not apply or induce pressure.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T07/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T07/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
