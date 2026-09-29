# A16 Tutorial: Model an operator install offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Operator architecture is modeled declaratively, not installed.** Read the synthetic CRD first: group `telemetry.example.test`, plural `signals`, kind `Signal`, namespace scope, served v1alpha1/v1, storage v1. Build six YAML documents in `$LAB/evidence/A16-operator.yaml`: compatible CRD, `Signal` named `harbor-signal`, one-replica `signal-operator` Deployment using busybox:1.36, same-named ServiceAccount, Role restricted to get/list/watch on `signals.telemetry.example.test`, and RoleBinding to that account. Put namespaced objects in `$NS`; owner label on every object and CRD prefix label on CRD. Validate locally with `kubectl create --dry-run=client -f ... -o yaml`; never apply/install. Ensure Role has no wildcard permissions.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A16/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A16/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
