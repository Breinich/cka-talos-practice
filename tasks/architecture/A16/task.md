# A16 — Model an operator install offline

| Field | Value |
|---|---|
| Task ID | `A16` |
| CKA pillar | `architecture` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

A synthetic Signal API is in `tasks/architecture/A16/resources/crd.yaml`; no CRD is installed. Create `.lab/A16/<namespace>/evidence/A16-operator.yaml` with a compatible CRD, namespaced `Signal` custom resource `harbor-signal`, controller Deployment `signal-operator`, ServiceAccount `signal-operator`, a namespaced Role restricted to get/list/watch Signals, and RoleBinding linking that ServiceAccount. Use one replica of `busybox:1.36` as a simulated controller (not a functional installation). Namespace resources must use the active lab namespace, every document the owner label, and the cluster-scoped CRD also the active `cka-lab.io/prefix` label. Model only: do not apply or install any operator.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a16`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A16/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Local artifacts only; never apply cluster-scoped definitions or rendered components. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A16` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A16/score.sh
./tasks/architecture/A16/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A16/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
