# A07 — Render a local release without installing it

| Field | Value |
|---|---|
| Task ID | `A07` |
| CKA pillar | `architecture` |
| Mode | `simulation` |
| Capability | `helm` |
| Points | 2 |

## Scenario and objective

The bundled chart `tasks/architecture/A07/resources/chart` defaults to one relay replica. With Helm installed, render release `harbor-relay` into `.lab/A07/<namespace>/evidence/A07-rendered.yaml` using `helm template` in the active namespace and override replicas to 2. The resulting Deployment must carry the release-derived name, namespace, two replicas, and the bundled container image. Do not use `helm install` or apply this render.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a07`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A07/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Local artifacts only; never apply cluster-scoped definitions or rendered components. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A07` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A07/score.sh
./tasks/architecture/A07/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A07/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
