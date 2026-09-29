# A05 Tutorial: Check both sides of the permission boundary

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Authorization checks answer effective permissions.** `can-i` evaluates the complete authorization chain; it is better evidence than reading a Role alone. This is a read-only check of the seeded identity.

Set the impersonated user exactly to `system:serviceaccount:$NS:relay-identity`. Run `kubectl auth can-i list pods --as="$USER" -n "$NS"` and `kubectl auth can-i delete pods --as="$USER" -n "$NS"`. Expected answers are `yes` and `no`. Also inspect the RoleBinding subject if results differ. Do not change RBAC just to make a response match; this check assumes A03’s least-privilege role state and makes no API edits.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A05/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A05/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
