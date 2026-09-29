# A14 — Check the API serving certificate

| Field | Value |
|---|---|
| Task ID | `A14` |
| CKA pillar | `architecture` |
| Mode | `read-only` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

Use a read-only TLS handshake to the configured API server (`openssl s_client` with hostname verification) without exporting credentials. In `.lab/A14/<namespace>/evidence/A14.json` record `host`, `issuer` (certificate RDNs as comma-joined `key=value` attributes), `notAfter` (ISO UTC), and `daysRemaining` as an integer from the actual leaf certificate. Confirm the expiry is in the future and the hostname matches the server; do not alter certs or Talos configuration.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a14`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A14/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Observation only; do not change cluster resources, certificates, host configuration or services. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A14` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A14/score.sh
./tasks/architecture/A14/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A14/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
