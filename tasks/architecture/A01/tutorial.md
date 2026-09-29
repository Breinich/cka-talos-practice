# A01 Tutorial: Read the live discovery surface

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Discovery API and scope.** Kubernetes discovery tells you whether an operation needs a namespace; Pod and Role are namespaced resources. No object mutation is called for.

Set `NS` from the active context, then collect only the version and discovery data: `kubectl version -o json`; `kubectl api-resources --namespaced=true`; `kubectl api-resources --api-group=rbac.authorization.k8s.io`. Build `.lab/A01/$NS/evidence/A01.json` with exactly `serverVersion` from `.serverVersion.gitVersion`, `podNamespaced: true`, and `roleGroup: "rbac.authorization.k8s.io"`. Do not dump kubeconfig. Verify the stored version is the server version, not client version, and both resource-discovery facts agree.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A01/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A01/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
