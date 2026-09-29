# W07 Tutorial: Use ConfigMap and Secret projections

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**ConfigMaps and Secrets should be referenced, not embedded in a Pod manifest.** Create owned ConfigMap `ember-settings` with `MODE=audit`, Opaque Secret `ember-token` with `TOKEN=dummy`, and Pod `ember-consumer` using `busybox:1.36`, `sh -c "sleep 7d"`. Define env entries with `valueFrom.configMapKeyRef` (`ember-settings`, key MODE) and `valueFrom.secretKeyRef` (`ember-token`, key TOKEN). Put ownership labels on objects and Pod. Verify references and Ready state using `kubectl -n "$NS" get pod ember-consumer -o yaml`; inspect ConfigMap keys only and never print/decode Secret contents. Avoid literal env values because that defeats reference semantics.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W07/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W07/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
