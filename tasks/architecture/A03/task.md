# A03 — Repair a restricted reader

| Field | Value |
|---|---|
| Task ID | `A03` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 3 |

## Scenario and objective

Setup seeds `relay-identity`, Role `relay-reader` with only `get` on Pods, and RoleBinding `relay-reader`. Inventory these three objects, then adjust the owned Role so that this identity can get, list and watch Pods, and cannot create, patch, delete, or access Secrets. Preserve the namespace-scoped binding and the exact subject. Verify via `kubectl auth can-i --as=system:serviceaccount:<namespace>:relay-identity -n <namespace>`.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a03`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; `.lab/A03/<namespace>/state.json` records their values.

## Safety boundary

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A03` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A03/score.sh
./tasks/architecture/A03/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A03/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
