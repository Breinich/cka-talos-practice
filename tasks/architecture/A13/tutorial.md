# A13 Tutorial: Upgrade an isolated kubeadm pair only

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Minor upgrades respect skew and preserve rollback.** Upgrade one minor at a time and control plane before worker; snapshot recovery is safer than improvising rollback.

Only for isolated snapshot-backed kubeadm VMs `cp-sandbox` and `worker-sandbox`, record baseline node versions and application response. Select a supported `N+1` release; review the matching kubeadm/kubelet release notes and version-skew policy. Upgrade control plane first, then drain the worker, update its kubelet/runtime packages as required, return it to service, and confirm both nodes at target version and application response. If any check fails, revert VM snapshots. **This is not a Talos procedure: do not run package upgrades, node drains, or kubeadm commands on the homelab.** No actual commands are needed for this unsupported lab exercise.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A13/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A13/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
