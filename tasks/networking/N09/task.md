# N09 — Triage a DNS timeout without editing CoreDNS

| Field | Value |
|---|---|
| Task ID | `N09` |
| CKA pillar | `networking` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario

Read the synthetic CoreDNS/client incident at `tasks/networking/N09/resources/coredns.txt` and the simulated resolver data in `tasks/networking/N09/resources/dns.json. A query from the lab namespace times out, even though the zone is served. No live CoreDNS read/write or CNI change is part of this task.

## Expected state

Write `.lab/N09/<namespace>/evidence/N09-incident.json` with `plugin`, `zone`, `name` (full queried FQDN), `blockedTransport`, `blockedPort`, and `repairScope` (one of `client-egress-policy` or `coredns-corefile`). Identify the blocking side and protocol/port rather than editing cluster DNS.

## Scope and constraints

Local artifact only under `.lab/N09/<namespace>/evidence/`; do not apply it or alter cluster/system resources. The validator reads it offline.
