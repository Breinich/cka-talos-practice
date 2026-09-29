# S06 — Protect an offline records volume

| Field | Value |
|---|---|
| Task ID | `S06` |
| CKA pillar | `storage` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario

The Lighthouse archive is moving to a retention-sensitive static volume. `tasks/storage/S06/resources/reclaim-broken.yaml` proposes a 128Mi classless PV and explicitly bound namespaced PVC, but its claim requests an incompatible access mode and its reclaim setting risks removing data. Produce `.lab/S06/<namespace>/evidence/S06-reclaim.yaml` using the active namespace/prefix. Keep the specified 128Mi hostPath model, explicit binding and `ReadWriteOnce` on both objects; change the PV policy so deletion of the claim does not request deletion of the backing volume.

## Scope and constraints

Offline only; do not apply the simulated PV/PVC to Talos. Host paths require a disposable kubeadm lab and separate data handling plan.
