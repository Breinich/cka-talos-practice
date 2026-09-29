# A04 — Run a non-API consumer without a token

| Field | Value |
|---|---|
| Task ID | `A04` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

The seeded `relay-identity` is restricted but an offline relay Pod does not need Kubernetes API access. Create owned Pod `relay-consumer` in the lab namespace using that identity, image `busybox:1.36`, and a long-running sleep command. Disable automatic token mounting on the Pod. Verify its effective ServiceAccount and Running state; do not alter the seeded ServiceAccount or bind additional privileges.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a04`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; `.lab/A04/<namespace>/state.json` records their values.

## Safety boundary

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A04` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A04/score.sh
./tasks/architecture/A04/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A04/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
