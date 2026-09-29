# A09 — Locate control-plane services without host access

| Field | Value |
|---|---|
| Task ID | `A09` |
| CKA pillar | `architecture` |
| Mode | `read-only` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

This Talos lab may expose static Pod mirrors in `kube-system`, but topology varies. Inspect `kubectl get pods -n kube-system -o wide` and the API server endpoint. In `.lab/A09/<namespace>/evidence/A09.json` record `apiServerPods`, `schedulerPods`, `controllerPods`, `etcdPods` as the complete arrays of matching static Pod mirror names (use empty arrays only when no matches are visible), plus `apiServerEndpoint` and `observedNodes` as all distinct node names in that Pod listing. Empty component arrays are allowed when Talos does not expose those mirrors; explain visibility limits in `notes`. Do not access nodes or restart components.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a09`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A09/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Observation only; do not change cluster resources, certificates, host configuration or services. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A09` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A09/score.sh
./tasks/architecture/A09/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A09/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
