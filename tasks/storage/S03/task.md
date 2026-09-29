# S03 — Bind a disposable data claim

| Field | Value |
|---|---|
| Task ID | `S03` |
| CKA pillar | `storage` |
| Mode | `conditional` |
| Capability | `storageclass` |
| Points | 2 |

## Scenario

If setup reports `STORAGECLASS=true`, an operator has selected a disposable storage backend. In the lab namespace, create owned PVC `lighthouse-live` requesting exactly 64Mi with `ReadWriteOnce` and the approved class in `.lab/S03/<namespace>/capabilities.env`. Create owned Pod `lighthouse-live-reader` with one container mounting that claim at `/data`; write `lighthouse-live-ready` to `/data/receipt` from that container. Verify both that the claim has real Bound capacity and that the Ready Pod reads the receipt. A `WaitForFirstConsumer` class may remain Pending until the Pod is scheduled. The two checks cover the class, access mode, requested/actual capacity and binding; then the running mounted consumer and receipt.

## Safety boundary

Do not modify StorageClasses or shared volumes. No PVC is created by setup. Opt in only after confirming a disposable backend and a manual data deletion plan; reset/restore/teardown refuse owned PVCs/PVs. Without approval the task is SKIP.

## Validation

```bash
./tasks/storage/S03/score.sh
./tasks/storage/S03/score.sh --json
```

The scorer checks two end-state criteria without printing a solution. `SKIP` excludes unavailable conditional storage from the denominator.

From any directory, run `./tasks/storage/S03/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
