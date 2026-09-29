# A12 — Bootstrap a disposable cluster only

| Field | Value |
|---|---|
| Task ID | `A12` |
| CKA pillar | `architecture` |
| Mode | `disposable-kubeadm` |
| Capability | `kubeadm` |
| Points | 3 |

## Scenario and objective

This is **UNSUPPORTED on Talos**. On two isolated, snapshot-backed kubeadm VMs named `cp-sandbox` and `worker-sandbox` (not homelab nodes), inventory runtime and kubelet readiness; initialize `cp-sandbox` with a VM-only API endpoint, install a VM-only CNI, then join `worker-sandbox` using a short-lived join token. Verify one Ready control-plane and one Ready worker, and that workload networking works. No validator exercises this on Talos; never execute these host commands here.

## Scope and constraints

Separate disposable VMs only; prohibited on Talos and this homelab. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A12` (including Pod templates). Never commit `.lab/` or credentials.
