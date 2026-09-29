# T11 Tutorial: Correlate control-plane signals

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**API readiness, static Pod Running, etcd service, and membership are separate signals.** Select control-plane node, query API `/readyz`, inspect kube-system Pods for component labels kube-apiserver/scheduler/controller-manager and node placement. Use `talosctl -n "$NODE" service etcd` and `talosctl -n "$NODE" get members -o json` read-only. Record controlPlaneNode, apiReady boolean, componentPods map to running Pod names, services.etcd=Running, memberCount = number of returned member objects. Verify exactly those components on chosen node; API not ready or missing mirrors should not be guessed. If Talos API unavailable, UNSUPPORTED. Never touch etcd/manifests/certs/services.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T11/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T11/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
