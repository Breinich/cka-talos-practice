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

Compare `/etc/resolv.conf` with a healthy Pod. Replace **only** the owned `dns-stray` Pod (DNS policy is immutable) so it uses `ClusterFirst` with no custom dnsConfig and retains the resolver container. Verify the replacement is Running and `nslookup web.$CKA_LAB_NAMESPACE.svc.cluster.local` inside it returns an address. When `CKA_LAB_NAMESPACE` is unset, use the configured prefix (default `cka-practice-t05`). Do not change cluster DNS.

## Safety boundary

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.

## Validation

```bash
./tasks/troubleshooting/T05/score.sh
./tasks/troubleshooting/T05/score.sh --json
```

The two criteria are checked independently. Hints and answers remain outside task prompts under `answers/`.

From any directory, run `./tasks/troubleshooting/T05/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
