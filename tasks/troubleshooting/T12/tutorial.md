# T12 Tutorial: Inspect Pod namespaces without host access

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Ephemeral containers provide constrained debugging without host namespaces.** Gate on permission to update `pods/ephemeralcontainers`; absent authorization means SKIP, do not elevate/install. For owned `toolbox`, run targeted `kubectl debug -n "$NS" pod/toolbox -it --target=toolbox --image=busybox:1.36 --container=inspect-<suffix> -- sh -c 'cat /proc/net/route; cat /proc/1/status'` (ensure no `--copy-to`, node target, host namespace, or sysadmin profile). Then inspect ephemeral container status/logs: it must terminate exit 0 and output route headers Iface/Destination and process Name. Debug is task-scoped; do not use host access.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T12/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T12/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
