# W09 — Use taints and tolerations safely

| Field | Value |
|---|---|
| Task ID | `W09` |
| CKA pillar | `workloads` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario

This is an **offline scheduling simulation**, not a request to taint nodes. `tasks/workloads/W09/resources/nodes.json` describes two synthetic workers; `oak-a` has one NoSchedule taint.

## Task

Inspect that inventory and write `${CKA_LAB_STATE_DIR:-.lab}/evidence/W09-pod.yaml` as an un-applied Pod named `ember-isolate` using `busybox:1.36`, CPU `5m` and memory `8Mi` requests. Target synthetic `oak-a` by hostname and add only the exact toleration needed for its taint. Never apply this file to the cluster.

## Expected state

The descriptor targets the intended synthetic hostname and image; the precise Equal/NoSchedule toleration and small requests are present without a wildcard toleration.

## Scope and constraints

This task is local-only. Do not apply the descriptor or alter real nodes.
