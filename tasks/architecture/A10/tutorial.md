# A10 Tutorial: Triage Talos services without repair

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Talos service inventory is read-only.** A service being stopped is an observation, not permission to restart it.

Choose a visible control-plane node from `kubectl get nodes`; when Talos access exists, run `talosctl health -n "$NODE"` and `talosctl services -n "$NODE"`. Record node, health status, kubelet/containerd running-or-stopped states and one literal service status line in `$LAB/evidence/A10.json`. Verify the chosen line is actually from that node’s output and service booleans/strings agree with observed state. Never save talosconfig, run `service restart`, reset or apply-config. If no Talos endpoint/access, record the supported unsupported result rather than guessing.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A10/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A10/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
