# A18 — Render a component overlay offline

| Field | Value |
|---|---|
| Task ID | `A18` |
| CKA pillar | `architecture` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

The synthetic collector at `tasks/architecture/A18/resources/component.yaml` is not a real cluster service. Copy the bundled component into `.lab/A18/<namespace>/evidence/A18-overlay` and create a Kustomize overlay there (Kustomize does not allow a base outside its load root); render `.lab/A18/<namespace>/evidence/A18-component.yaml` with `kubectl kustomize`. Adjust to two replicas and the active namespace, preserving the owner label on Deployment and Pod template. The scorer independently rebuilds your overlay and compares semantic output with the saved render. Do not apply the component.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a18`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A18/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Local artifacts only; never apply cluster-scoped definitions or rendered components. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A18` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A18/score.sh
./tasks/architecture/A18/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A18/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
