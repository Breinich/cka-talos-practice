# A07 Tutorial: Render a local release without installing it

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Helm template renders are local output, not releases.** `helm template` evaluates chart templates without creating a release or contacting the API server.

Inspect `tasks/architecture/A07/resources/chart/Chart.yaml` and values to learn the image and template naming. Chart `values.yaml` uses key `replicas`, so render with `helm template harbor-relay tasks/architecture/A07/resources/chart -n "$NS" --set replicas=2 > "$LAB/evidence/A07-rendered.yaml"`. Inspect the result with `grep`/`yq` or `kubectl create --dry-run=client -f ... -o yaml`; verify Deployment name `harbor-relay-relay`, active namespace, two replicas, selector/template label `app=harbor-relay-relay`, and image `nginx:1.27-alpine`. Do not use `helm install` or apply the render.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A07/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A07/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
