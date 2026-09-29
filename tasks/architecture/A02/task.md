# A02 — Scope a temporary client identity

| Field | Value |
|---|---|
| Task ID | `A02` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 3 |

## Scenario and objective

Setup supplies ServiceAccount `relay-identity` and a namespaced Role permitting Pod get. Operations need a separate kubeconfig at `.lab/A02/<namespace>/evidence/A02.kubeconfig` for this identity only. Obtain a short-lived token using `kubectl create token relay-identity -n <lab namespace> --duration=10m`; include only the current cluster server/CA, the token identity and one context. Check that it can get Pod `toolbox` but cannot delete Pods. Keep the file mode 0600; do not copy an admin credential. Token expiration means this task must be scored shortly after creation.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a02`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; `.lab/A02/<namespace>/state.json` records their values.

## Safety boundary

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A02` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A02/score.sh
./tasks/architecture/A02/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A02/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
