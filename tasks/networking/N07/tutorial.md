# N07 Tutorial: Translate the entrypoint into header routing

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**HTTPRoute rule ordering matters: header-specific match must precede fallback path match.** Offline manifest `gateway.networking.k8s.io/v1` HTTPRoute `estuary-route`, namespace `$NS`, owned label, parentRef name `estuary-gateway`, sectionName `http`, hostname `estuary.lab.invalid`. First rule matches path prefix `/v1` AND exact header `x-estuary-tier: canary` to `estuary-port:8080`; second matches `/v1` to `estuary-front:8080`. Use distinct rule entries in that order. Check refs and backend port refs. These CRDs/Gateway are not installed: render/parse only; no Accepted/Programmed claim and never apply.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/N07/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/networking/N07/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
