# A08 — Promote a local overlay into the lab

| Field | Value |
|---|---|
| Task ID | `A08` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

Setup copies `tasks/architecture/A08/resources/kustomize/base` (one replica, no namespace or ownership marker) to `.lab/A08/<namespace>/A08-kustomize/`. Complete that instance's `.lab/A08/<namespace>/A08-kustomize/overlay/kustomization.yaml` so `kubectl kustomize` produces Deployment `<prefix>-kustom-app`, in the active namespace, with two replicas and the owner label on both object and Pod template. Apply only that Deployment to the owned namespace and verify its rollout. Do not touch the base.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a08`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; `.lab/A08/<namespace>/state.json` records their values.

## Safety boundary

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A08` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A08/score.sh
./tasks/architecture/A08/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A08/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
