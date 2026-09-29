# A15 — Inventory admission without changing it

| Field | Value |
|---|---|
| Task ID | `A15` |
| CKA pillar | `architecture` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

Setup creates a dedicated namespace with Pod Security `audit` and `warn` labels set to `baseline`, without enforcement. Inspect; change **only this task namespace's** `pod-security.kubernetes.io/enforce` label to `baseline`. In `.lab/A15/<namespace>/evidence/A15.json` record `validatingWebhookCount`, `mutatingWebhookCount`, and `podSecurityEnforce` (`baseline`). Verify the counts against the live lists and namespace label; do not submit a privileged probe Pod or edit shared admission objects.

## Scope and constraints

Only the isolated task namespace may change; do not alter shared admission objects, certificates, host configuration or services. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A15` (including Pod templates). Never commit `.lab/` or credentials.
