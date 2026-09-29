# A12 Tutorial: Bootstrap a disposable cluster only

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Bootstrap lifecycle and safety.** This task is intentionally outside Talos. A kubeadm bootstrap requires compatible runtime/kubelet, API reachability, CNI and short-lived join credentials. There is no task scorer performing these host operations.

Only in two disposable, snapshot-backed VMs `cp-sandbox` and `worker-sandbox`, document a runbook: inventory versions/readiness; select a private VM-only API endpoint; initialize control plane; install a CNI compatible with chosen Kubernetes version; create a short-lived join token and join worker; verify one Ready control-plane and worker plus cross-Pod networking. Take/revert snapshots on failure. The conceptual validation sequence is `kubectl get nodes -o wide`, `kubectl get pods -A`, and a disposable in-cluster connectivity test. **Do not copy/run bootstrap, package, token, or host commands against Talos or this homelab.**

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A12/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A12/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
