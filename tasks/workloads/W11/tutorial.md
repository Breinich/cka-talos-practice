# W11 Tutorial: Use probes and security context

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Probes gate readiness/liveness; securityContext reduces container privilege.** Create owned Pod `ember-guard` with container busybox:1.36 running foreground `httpd -f -p 8080`, container `runAsUser: 10001` and `allowPrivilegeEscalation: false`. Add both `readinessProbe` and `livenessProbe` as `tcpSocket.port: 8080` (reasonable initial delay/period), expose containerPort 8080 if desired. Apply only in `$NS`. Check Pod Ready and inspect probe events with `kubectl describe pod ember-guard -n "$NS"`. Port 8080 avoids privileged port restrictions; do not put securityContext only at Pod level if scorer requires container-level field.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/W11/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/workloads/W11/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
