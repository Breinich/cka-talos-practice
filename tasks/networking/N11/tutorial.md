# N11 Tutorial: Model two service exposures without applying them

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**NodePort and ExternalName have different Service semantics.** Offline two owned Service docs in configured namespace. `estuary-node-demo`: type NodePort, selector `app: estuary-api`, port name `http`, port 8080, targetPort `http`, nodePort 30081. `estuary-alias-demo`: type ExternalName, `externalName: estuary.lab.invalid` (no selector/ports). Validate local/client dry-run only. Ownership labels apply; do not apply because NodePort could expose the homelab workload. Avoid giving ExternalName a ClusterIP selector or adding a public backend assumption.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/N11/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/networking/N11/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
