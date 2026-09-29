# N09 Tutorial: Triage a DNS timeout without editing CoreDNS

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**CoreDNS serving a zone does not imply client packets can reach DNS.** Read both `resources/coredns.txt` and dns.json. Corefile serves cluster.local and forwards external names; the simulated query is cluster FQDN via UDP/53, but egress permits only TCP/53. Thus identify UDP/53 blocked at client policy and choose `client-egress-policy`, not CoreDNS Corefile. Write exact plugin/zone/name/blockedTransport/blockedPort/repairScope to N09-incident.json. Verify source says `kubernetes cluster.local` and egress mismatch. Do not inspect/edit live CoreDNS or CNI.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/N09/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/networking/N09/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
