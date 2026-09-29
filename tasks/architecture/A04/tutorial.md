# A04 Tutorial: Run a non-API consumer without a token

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Disable unused API credentials.** Pod identity and API token projection are separate controls: assign the existing restricted account but disable automatic token mounting for a process that does not call Kubernetes.

Inspect the seeded ServiceAccount, then create `relay-consumer` as an owned Pod in `$NS`, using `serviceAccountName: relay-identity`, `automountServiceAccountToken: false`, container `busybox:1.36`, and a long-running sleep process. Apply only this namespaced Pod manifest. Verify `kubectl -n "$NS" get pod relay-consumer -o jsonpath='{.spec.serviceAccountName} {.spec.automountServiceAccountToken} {.status.phase}'` shows the expected account, false, Running. Do not alter the ServiceAccount token policy or grant privileges.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A04/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A04/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
