# N02 Tutorial: Publish a headless peer list

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Headless Services publish Pod DNS records through EndpointSlices.** Inspect `estuary-api` selector labels and named HTTP port. Create owned Service `estuary-peers` with `clusterIP: None`, selector exactly `app: estuary-api`, and port `{name: http, port: 8080, targetPort: http}` in `$NS`. Apply manifest with owner/task labels. Verify `kubectl get svc estuary-peers -o yaml` shows clusterIP None, then inspect EndpointSlices labeled `kubernetes.io/service-name=estuary-peers`; ready addresses should reference API Pods and backend port 80. Do not copy Deployment’s containerPort 80 as Service port; task Service port is 8080.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/N02/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/networking/N02/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
