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

## Safety boundary

Local artifact only under `.lab/N04/<namespace>/evidence/`; do not apply it or alter cluster/system resources. The validator reads it offline.

## Validation

```bash
./tasks/networking/N04/score.sh
./tasks/networking/N04/score.sh --json
```

Two independent criteria are scored without printing a solution. Solutions are not included in prompts.

From any directory, run `./tasks/networking/N04/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
