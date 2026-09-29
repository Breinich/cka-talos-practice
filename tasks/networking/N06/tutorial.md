# N06 Tutorial: Draft the legacy entrypoint offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Ingress is an API object and needs a controller/class to route traffic; this one is migration YAML only.** Produce `networking.k8s.io/v1` Ingress `estuary-entry` in `$NS` with owner label, `spec.ingressClassName: offline-estuary`, one rule host `estuary.lab.invalid`, HTTP path `/v1`, `pathType: Prefix`, backend Service `estuary-front`, port number 8080. Validate YAML client-side; do not create IngressClass, DNS, controller, or apply. Check hostname, class, path type and backend fields exactly; a working route cannot be claimed without controller.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/N06/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/networking/N06/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
