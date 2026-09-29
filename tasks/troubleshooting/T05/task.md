# T05 — Repair a Pod-local DNS fault

| Field | Value |
|---|---|
| Task ID | `T05` |
| CKA pillar | `troubleshooting` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The owned `dns-stray` Pod has DNS policy `None` and a documentation-only resolver `192.0.2.53`; `web` is a healthy Service in the same namespace.

## Required outcome

Compare `/etc/resolv.conf` with a healthy Pod. Replace **only** the owned `dns-stray` Pod (DNS policy is immutable) so it uses `ClusterFirst` with no custom dnsConfig and retains the resolver container. Verify the replacement is Running and inside it returns an address. When `CKA_LAB_NAMESPACE` is unset, use the configured prefix (default `cka-practice-t05`). Do not change cluster DNS.

## Scope and constraints

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.
