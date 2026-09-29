# S01 Tutorial: Restore the shared workspace

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**emptyDir lifetime is Pod lifetime; volume definition is shared by mounts.** Inspect Deployment `lighthouse-workspace` and its containers/mounts. Add the existing volume name `workspace` at `/workspace` to consumer `volumeMounts`, matching producer’s `emptyDir`; preserve replica count and images. Apply/rollout and wait before writing receipt because rollout replaces Pod. Then `kubectl exec -n "$NS" deploy/lighthouse-workspace -c producer -- sh -c 'echo lighthouse-ready > /workspace/receipt'`; read same path from consumer. Verify mount names/types and exact content. Never write before rollout or use node/PV storage.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/S01/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/storage/S01/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
