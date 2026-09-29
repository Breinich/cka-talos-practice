# T08 Tutorial: Read a metrics snapshot

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Metrics API values are live snapshots and require correct units/names.** Gate on setup capability and verify both `kubectl top nodes` and `kubectl top pods -n "$NS"` work; if either unavailable, SKIP (no install/load). Wait for seeded `web-...` Pod and metrics row. Create `$LAB/evidence/T08.sh` containing `#!/usr/bin/env bash`, `set -euo pipefail`, `kubectl top nodes`, and `kubectl top pods -n "$NS"`; make it executable and run it. Save `T08.json` as `{"node":"<actual node row>","namespace":"$NS","pod":"<actual web-... pod row>"}`. Ensure those exact named rows currently display CPU in millicores and memory in Mi; scorer queries current metrics, so pasted output is not evidence. Do not fabricate values or query another namespace.

## Task-scoped workflow: capability-gated

Check this task's capability/approval first. If unavailable or unapproved, stop with SKIP; do not install optional shared infrastructure (metrics server, storage class/backend, debug permissions, or controllers). If supported, perform only the explicitly task-directed work on this task's owned resources in its unique namespace. Respect the task's data-cleanup boundary; a storage claim may require manual data review before cleanup.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
