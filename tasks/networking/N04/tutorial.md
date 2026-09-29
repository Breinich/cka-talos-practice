# N04 Tutorial: Resolve a search-path incident offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Resolver search order plus ndots determines candidate names.** Read `resources/dns.json`: query is short `estuary-front`, source namespace is active namespace, ndots=5, search list starts `<ns>.svc.cluster.local`, and simulated IP mapping lists front `10.96.12.21`, port `10.96.12.22`. Since short name has fewer than five dots, resolver tries search suffix first; expected qualified name `estuary-front.<ns>.svc.cluster.local`, address front IP, other address port IP, reason `namespace-search`. Write fields query, qualifiedName, resolvedAddress, otherServiceAddress, reason into N04-dns.json. Verify addresses are copied from input, not live cluster DNS.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/N04/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/networking/N04/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
