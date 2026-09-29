# W05 — Create a node-spanning DaemonSet

| Field | Value |
|---|---|
| Task ID | `W05` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

There is no `ember-observer` DaemonSet. Eligible nodes are Ready, schedulable workers labeled `node-role.kubernetes.io/worker`; do not touch nodes. Use the task namespace (default `cka-practice-w05`).

## Task

Discover the eligible workers. Create an owned `ember-observer` DaemonSet selecting `app=ember-observer`, targeting only worker-labeled nodes and using `busybox:1.36` with CPU `5m`/memory `8Mi` requests and a long-running process. Do not add a toleration that bypasses taints.

## Expected state

The Pod template targets workers with tiny requests; exactly one ready Pod runs per eligible worker. If none exist this exercise is SKIP.

## Scope and constraints

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W05` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.
