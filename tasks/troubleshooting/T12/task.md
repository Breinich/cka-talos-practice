# T12 — Inspect Pod namespaces without host access

| Field | Value |
|---|---|
| Task ID | `T12` |
| CKA pillar | `troubleshooting` |
| Mode | `conditional` |
| Capability | `debug` |
| Points | 2 |

## Scenario

This is **conditional** on permission to update `pods/ephemeralcontainers`. The owned `toolbox` Pod is disposable; the host and other namespaces are not.

## Required outcome

Inspect the owned `toolbox` Pod with a single targeted ephemeral container named `inspect-<suffix>` using `busybox:1.36`; it must print process status and network-route information. Do not use `--copy-to`, `--profile=sysadmin`, host namespaces or a node target. Verify the ephemeral container terminated successfully and its logs contain both network-route headers (`Iface`, `Destination`) and process `Name`. If debug authorization is absent, expect SKIP.

## Scope and constraints

Only owned resources in the configured lab namespace; no host, node or cluster-scoped changes.
