# A14 Tutorial: Check the API serving certificate

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**TLS certificate inspection without credential export.** The API endpoint’s leaf certificate can be inspected during a TLS handshake; the client certificate/private key is not needed for the server certificate fields.

Derive host from current API server URL, then inspect using `openssl s_client -connect "$HOST:6443" -servername "$HOST" -verify_hostname "$HOST" </dev/null 2>/dev/null | openssl x509 -noout -issuer -enddate -subject`. If endpoint is on a nondefault port, use its configured port rather than assuming 6443. Convert the leaf `notAfter` to ISO UTC and compute integer days remaining; normalize issuer RDNs to comma-joined `key=value`. Verify hostname matches certificate SAN and expiration is future. Store only host/issuer/notAfter/daysRemaining in `$LAB/evidence/A14.json`. Never export or persist kubeconfig credentials or private keys.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A14/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A14/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
