# N01 Tutorial: Repair the front door

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Service selectors create EndpointSlices; Service port and targetPort differ.** Inspect `estuary-api` Pod labels/ports, `estuary-front`, and its EndpointSlices: `kubectl -n "$NS" get deploy estuary-api --show-labels`; `kubectl -n "$NS" get svc estuary-front -o yaml`; `kubectl -n "$NS" get endpointslice -l kubernetes.io/service-name=estuary-front -o yaml`. Fix only selector to `app: estuary-api`, retain ClusterIP and port 8080 with named targetPort `http`. Apply/patch Service. Verify ready EndpointSlice address and port 80 while Service stays 8080. Do not point selector at catalog or edit controller-created EndpointSlice.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/N01/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/networking/N01/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
