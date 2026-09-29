# A15 Tutorial: Inventory admission without changing it

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Pod Security Admission labels are namespaced; webhook inventory is cluster-scoped and read-only.** Change only the dedicated task namespace enforcement label.

Inspect counts with `kubectl get validatingwebhookconfigurations -o name` and mutating equivalent; inspect namespace labels with `kubectl get ns "$NS" --show-labels`. Set only `pod-security.kubernetes.io/enforce=baseline` on `$NS` (e.g. `kubectl label namespace "$NS" pod-security.kubernetes.io/enforce=baseline --overwrite`). Write fresh counts and label to `$LAB/evidence/A15.json`. Verify existing audit/warn labels stay baseline and counts equal current lists. Do not edit webhook configurations or submit a privileged probe.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A15/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A15/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
