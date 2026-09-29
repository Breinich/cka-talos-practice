# A15 — Inventory admission without changing it

| Field | Value |
|---|---|
| Task ID | `A15` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

Setup creates a dedicated namespace with Pod Security `audit` and `warn` labels set to `baseline`, without enforcement. Inspect `kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations`; change **only this task namespace's** `pod-security.kubernetes.io/enforce` label to `baseline`. In `.lab/A15/<namespace>/evidence/A15.json` record `validatingWebhookCount`, `mutatingWebhookCount`, and `podSecurityEnforce` (`baseline`). Verify the counts against the live lists and namespace label; do not submit a privileged probe Pod or edit shared admission objects.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a15`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; `.lab/A15/<namespace>/state.json` records their values.

## Safety boundary

Only the isolated task namespace may change; do not alter shared admission objects, certificates, host configuration or services. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A15` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A15/score.sh
./tasks/architecture/A15/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A15/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
