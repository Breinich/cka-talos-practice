# T10 Tutorial: Trace kubelet to its runtime

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Kubernetes runtime version and Talos service state are complementary evidence.** Find toolbox placement with `kubectl -n "$NS" get pod toolbox -o wide`, fetch node `.status.nodeInfo.containerRuntimeVersion` and Pod `.spec.runtimeClassName` (empty string if absent). On that same node, use read-only `talosctl -n "$NODE" service kubelet` and `talosctl -n "$NODE" service containerd`; record both state Running and values in T10.json. Compare node/runtime exactly to API. If Talos access absent, UNSUPPORTED. No SSH, crictl install, restart or config mutation.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T10/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T10/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
