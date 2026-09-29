# W09 Tutorial: Use taints and tolerations safely

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Tolerations admit a Pod through matching taints but do not select a node.** This is offline. Read `resources/nodes.json`: oak-a has hostname `oak-a` and taint key `training.example.test/isolated`, value `yes`, effect `NoSchedule`. Write local Pod `ember-isolate` with nodeSelector `kubernetes.io/hostname: oak-a`; one busybox:1.36 container, requests 5m/8Mi, and only toleration `{key: training.example.test/isolated, operator: Equal, value: "yes", effect: NoSchedule}`. Save `${CKA_LAB_STATE_DIR:-.lab}/evidence/W09-pod.yaml`. Verify exact matching and no wildcard operator. Never apply or modify real nodes.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W09/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W09/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
