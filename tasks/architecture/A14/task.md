# A14 — Check the API serving certificate

| Field | Value |
|---|---|
| Task ID | `A14` |
| CKA pillar | `architecture` |
| Mode | `read-only` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

Use a read-only TLS handshake to the configured API server with hostname verification without exporting credentials. In `.lab/A14/<namespace>/evidence/A14.json` record `host`, `issuer` (certificate RDNs as comma-joined `key=value` attributes), `notAfter` (ISO UTC), and `daysRemaining` as an integer from the actual leaf certificate. Confirm the expiry is in the future and the hostname matches the server; do not alter certs or Talos configuration.

## Scope and constraints

Observation only; do not change cluster resources, certificates, host configuration or services. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A14` (including Pod templates). Never commit `.lab/` or credentials.
