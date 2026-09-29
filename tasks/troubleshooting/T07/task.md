# T07 — Rank eviction candidates offline

| Field | Value |
|---|---|
| Task ID | `T07` |
| CKA pillar | `troubleshooting` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario

This is a **simulation**: `tasks/troubleshooting/T07/resources/qos.yaml` describes three equal-priority, single-container Pods. The archive index has Burstable QoS because requests are below limits; the scratch probe is BestEffort. Assume memory pressure and that the cache exceeds its memory request. No node pressure will be induced.

## Required outcome

Copy the three documents to `.lab/T07/<namespace>/evidence/T07-pods.yaml` (or `$CKA_LAB_STATE_DIR/evidence/`). Change **only** `archive-index` to Guaranteed by setting CPU request and limit to `50m`, memory request and limit to `32Mi. In `T07.json`, record keys `first`, `second`, and `last` with the three Pod names in predicted eviction order, plus `pressure` set to `memory` and `equalPriority` set to `true. Check the manifest and the order independently; do not apply it to the cluster.

## Scope and constraints

No live changes; simulation only.
