# N04 — Resolve a search-path incident offline

| Field | Value |
|---|---|
| Task ID | `N04` |
| CKA pillar | `networking` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario

The synthetic resolver input is `tasks/networking/N04/resources/dns.json`; `__NAMESPACE__` means the active lab namespace. It records two fixed simulated Service IPs, an unqualified query and an ndots/search configuration. Without querying or modifying live DNS, write `.lab/N04/<namespace>/evidence/N04-dns.json` describing the first matching FQDN and the two resulting simulated addresses.

## Expected state

Output JSON fields: `query` (original short name), `qualifiedName`, `resolvedAddress`, `otherServiceAddress`, and `reason` (one of `namespace-search` or `external-forward`). The two independent checks test search-path choice and both expected IPs; this is an offline simulation, not proof of a real cluster lookup.

## Scope and constraints

Local artifact only under `.lab/N04/<namespace>/evidence/`; do not apply it or alter cluster/system resources. The validator reads it offline.
