# A13 — Upgrade an isolated kubeadm pair only

| Field | Value |
|---|---|
| Task ID | `A13` |
| CKA pillar | `architecture` |
| Mode | `disposable-kubeadm` |
| Capability | `kubeadm` |
| Points | 3 |

## Scenario and objective

This is **UNSUPPORTED on Talos**. Starting with an isolated snapshot-backed pair `cp-sandbox` / `worker-sandbox` at Kubernetes version N, choose an available N+1 minor release respecting version skew. Record baseline Ready nodes and workload service response; upgrade the control plane and packages, then safely drain, upgrade and return the worker to service, verifying both versions and service response afterward. Roll back the VM snapshots if checks fail. Never perform package management, node maintenance or cluster upgrades on this homelab.

## Scope and constraints

Separate disposable VMs only; prohibited on Talos and this homelab. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A13` (including Pod templates). Never commit `.lab/` or credentials.
