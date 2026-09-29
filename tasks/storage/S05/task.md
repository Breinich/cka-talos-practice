# S05 — Grow a bound disposable claim

| Field | Value |
|---|---|
| Task ID | `S05` |
| CKA pillar | `storage` |
| Mode | `conditional` |
| Capability | `expandable` |
| Points | 2 |

## Scenario

Independently of S03, if setup reports `EXPANDABLE=true`, create an owned 64Mi claim and consumer first, write the receipt, then increase its `lighthouse-live` request to exactly 128Mi using its approved class. Wait for both requested and reported capacity to reach 128Mi while the claim remains Bound. Keep `lighthouse-live-reader` Ready, mounted at `/data`, and able to read this task's `/data/receipt` containing `lighthouse-live-ready`. The independent checks are the expanded requested/actual PVC capacity and the consuming Pod's persisted receipt. An expansion-in-progress is not a completed task; never shrink a PVC.

## Scope and constraints

Only the manually approved disposable class and lab-owned claim/Pod may be touched. No controller, node or PV mutation. If expansion is unapproved/unsupported, SKIP. Manual data review and cleanup are required before reset, restore or teardown.
