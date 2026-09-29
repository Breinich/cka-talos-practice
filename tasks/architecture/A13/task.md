# A13 — Upgrade an isolated kubeadm pair only

| Field | Value |
|---|---|
| Task ID | `A13` |
| CKA pillar | `architecture` |
| Mode | `disposable-kubeadm` |
| Capability | `kubeadm` |
| Points | 3 |

## Scenario and objective

This is **UNSUPPORTED on Talos**. Starting with an isolated snapshot-backed pair `cp-sandbox` / `worker-sandbox` at Kubernetes version N, choose an available N+1 minor release respecting version skew. Record baseline Ready nodes and workload service response; upgrade control plane with kubeadm and packages, then drain/upgrade/uncordon worker, verifying both versions and service response afterward. Roll back the VM snapshots if checks fail. Never run package management, drain, or kubeadm upgrade on this homelab.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a13`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A13/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Separate disposable VMs only; prohibited on Talos and this homelab. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A13` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A13/score.sh
./tasks/architecture/A13/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A13/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
