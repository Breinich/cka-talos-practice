# A01 — Read the live discovery surface

| Field | Value |
|---|---|
| Task ID | `A01` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

The dispatch team needs to know whether Pod and Role are namespaced before applying a scoped change. The current context is the configured Talos lab; no API objects need changing. Run `kubectl version -o json`, `kubectl api-resources --namespaced=true` and `kubectl api-resources --api-group=rbac.authorization.k8s.io`. Save `.lab/A01/<namespace>/evidence/A01.json` with `serverVersion` (the server gitVersion), `podNamespaced` (boolean), and `roleGroup` (`rbac.authorization.k8s.io`). Do not save credentials or the full kubeconfig. The scorer compares version and both discovery facts against the live API.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a01`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; `.lab/A01/<namespace>/state.json` records their values.

## Safety boundary

Only owned namespaced objects in the active lab namespace may change. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A01` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A01/score.sh
./tasks/architecture/A01/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A01/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
