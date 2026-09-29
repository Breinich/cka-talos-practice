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

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a12`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A12/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Separate disposable VMs only; prohibited on Talos and this homelab. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A12` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A12/score.sh
./tasks/architecture/A12/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A12/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
