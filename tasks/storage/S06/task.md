# S06 — Protect an offline records volume

| Field | Value |
|---|---|
| Task ID | `S06` |
| CKA pillar | `storage` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario

The Lighthouse archive is moving to a retention-sensitive static volume. `tasks/storage/S06/resources/reclaim-broken.yaml` proposes a 128Mi classless PV and explicitly bound namespaced PVC, but its claim requests an incompatible access mode and its reclaim setting risks removing data. Produce `.lab/S06/<namespace>/evidence/S06-reclaim.yaml` using the active namespace/prefix. Keep the specified 128Mi hostPath model, explicit binding and `ReadWriteOnce` on both objects; change the PV policy so deletion of the claim does not request deletion of the backing volume. The checks separately verify the exact matching access/binding fields and safe reclaim policy. No claim or PV should actually be deleted.

## Safety boundary

Offline only; do not apply the simulated PV/PVC to Talos. Host paths require a disposable kubeadm lab and separate data handling plan.

## Validation

```bash
./tasks/storage/S06/score.sh
./tasks/storage/S06/score.sh --json
```

The scorer checks two end-state criteria without printing a solution. `SKIP` excludes unavailable conditional storage from the denominator.

From any directory, run `./tasks/storage/S06/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
