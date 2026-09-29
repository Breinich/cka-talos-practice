# A03 Tutorial: Repair a restricted reader

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Least-privilege RBAC.** Role rules are additive; RoleBinding subjects determine who gets them. Edit only namespaced Role `relay-reader`, preserving RoleBinding `relay-reader` and its ServiceAccount subject.

Inspect both objects: `kubectl -n "$NS" get role relay-reader,rolebinding relay-reader -o yaml`. Set the Role rule to `apiGroups: [""]`, `resources: ["pods"]`, `verbs: ["get","list","watch"]`; no Secrets rule and no create/patch/delete verbs. For example, patch the existing rule declaratively with `kubectl -n "$NS" edit role relay-reader` and save. Verify using `kubectl auth can-i list pods --as=system:serviceaccount:$NS:relay-identity -n "$NS"` and repeat for delete pods and get secrets (both no). Do not recreate the binding or broaden to ClusterRole.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A03/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A03/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
