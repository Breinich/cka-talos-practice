# A09 Tutorial: Locate control-plane services without host access

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Static Pod mirrors are an API-visible view, not host access.** Inventory only what the API exposes; Talos may not publish etcd mirrors.

Use `kubectl get pods -n kube-system -o wide` and `kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'` for the endpoint. Classify complete Pod-name arrays by component substring (`kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, `etcd`) and collect unique `.spec.nodeName` values from the listing. Write all four arrays (empty only if genuinely absent), endpoint, observedNodes and a note explaining invisible mirrors to `$LAB/evidence/A09.json`. Verify no duplicates and that arrays reflect the whole listing. Never SSH to a node or restart a static Pod.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A09/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A09/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
