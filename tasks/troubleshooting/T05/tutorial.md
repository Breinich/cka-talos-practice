# T05 Tutorial: Repair a Pod-local DNS fault

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Pod DNS policy `None` bypasses cluster search/resolver setup; DNS policy is immutable.** Compare `kubectl exec -n "$NS" <healthy-pod> -c <resolver> -- cat /etc/resolv.conf` with `dns-stray`. Preserve its image/container/labels from `kubectl get pod dns-stray -n "$NS" -o yaml`; remove server-generated metadata, set `dnsPolicy: ClusterFirst`, remove `dnsConfig`, and keep container unchanged. Because Pod DNS policy is immutable, delete only `dns-stray` and recreate it from the corrected manifest. Verify Running, then `kubectl exec -n "$NS" dns-stray -- nslookup web.$NS.svc.cluster.local`; result should include a Service address. Use actual configured namespace in FQDN. Do not change CoreDNS or leave documentation-only 192.0.2.53 nameserver.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/T05/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/troubleshooting/T05/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
