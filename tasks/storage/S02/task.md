# S02 — Repair an offline archive binding

| Field | Value |
|---|---|
| Task ID | `S02` |
| CKA pillar | `storage` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 3 |

## Scenario

A records team prepared `tasks/storage/S02/resources/static-broken.yaml`: an unbound static archive and reader. Render `__PREFIX__` and `__NAMESPACE__` using the active lab scope, repair the mismatched claim size and access mode, and correct the reader's claim reference. Save all three documents as `.lab/S02/<namespace>/evidence/S02-static.yaml. The PV must remain a 256Mi classless `ReadWriteOnce` hostPath model at `/var/local/lighthouse-archive`, explicitly selected by the namespaced claim, with `Retain` reclamation. The reader must mount that claim at `/archive. Checks independently cover matching PV/PVC binding fields and the consuming Pod's mount. You may inspect with if available; it does not prove server-side binding.

## Scope and constraints

Offline simulation only. Never apply a hostPath PV or this Pod on Talos: no safe node directory or static backend is assumed. Live binding requires a disposable kubeadm lab with an explicitly prepared empty path.
