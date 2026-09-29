# T09 — Build a node pressure inventory

| Field | Value |
|---|---|
| Task ID | `T09` |
| CKA pillar | `troubleshooting` |
| Mode | `read-only` |
| Capability | `core` |
| Points | 2 |

## Scenario

Read-only node inspection: a healthy-looking Pod may still be blocked by node pressure or taints. Choose one existing node; do not create pressure.

## Required outcome

Write `.lab/T09/<namespace>/evidence/T09.json` (or state-dir equivalent) with `node`, `conditions` (Ready, MemoryPressure, DiskPressure, PIDPressure status strings), `taints` (the actual spec taint list, or `[]`), and `capacity` and `allocatable` objects each containing exact `cpu` and `memory` quantities from that node. Check the condition/taint snapshot and the capacity/allocatable comparison independently. Do not patch nodes.

## Safety boundary

Read-only; no node, control-plane or Talos machine changes.

## Validation

```bash
./tasks/troubleshooting/T09/score.sh
./tasks/troubleshooting/T09/score.sh --json
```

The two criteria are checked independently. Hints and answers remain outside task prompts under `answers/`.

From any directory, run `./tasks/troubleshooting/T09/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
