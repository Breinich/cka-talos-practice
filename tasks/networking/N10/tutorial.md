# N10 Tutorial: Check the repaired service through a local tunnel

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Port-forward tests Service routing locally without public exposure.** Check seeded `estuary-front` selector/endpoints are ready before tunnel. Run `kubectl -n "$NS" port-forward service/estuary-front 18080:8080`, in another shell request `curl -sS -o /tmp/body -w '%{http_code}' http://127.0.0.1:18080/`, then stop the forward with Ctrl-C. Record namespace, service, localPort=18080, remotePort=8080, actual HTTP status and body in N10-forward.json; do not include credentials. Verify success response and live ready endpoint. No NodePort/public listener; tunnel process must be stopped.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/N10/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/networking/N10/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
