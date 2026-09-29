# A06 — Classify an uninstalled API extension

| Field | Value |
|---|---|
| Task ID | `A06` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

`tasks/architecture/A06/resources/crd.yaml` is a synthetic API definition, not installed on the cluster. Inspect it offline. Write `.lab/A06/<namespace>/evidence/A06.json` with `group`, `scope`, `plural`, `servedVersions` (array), and `storageVersion` matching that definition. Determine which endpoint a namespaced client would discover and put it in `resourcePath`, using the active namespace. Never apply this CRD.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a06`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A06/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Local evidence only; do not create cluster objects. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A06` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A06/score.sh
./tasks/architecture/A06/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A06/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
