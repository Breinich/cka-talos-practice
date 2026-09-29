# A14 Tutorial: Check the API serving certificate

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**TLS certificate inspection without credential export.** The API endpoint’s leaf certificate can be inspected during a TLS handshake; the client certificate/private key is not needed for the server certificate fields.

Derive host from current API server URL, then inspect using `openssl s_client -connect "$HOST:6443" -servername "$HOST" -verify_hostname "$HOST" </dev/null 2>/dev/null | openssl x509 -noout -issuer -enddate -subject`. If endpoint is on a nondefault port, use its configured port rather than assuming 6443. Convert the leaf `notAfter` to ISO UTC and compute integer days remaining; normalize issuer RDNs to comma-joined `key=value`. Verify hostname matches certificate SAN and expiration is future. Store only host/issuer/notAfter/daysRemaining in `$LAB/evidence/A14.json`. Never export or persist kubeconfig credentials or private keys.

## Task-scoped workflow: read-only observations

Use only read operations for the named API endpoint/node and write evidence locally. Do not create a namespace or change any Kubernetes resource. Derive evidence from fresh observations; no object edit or cleanup is needed. If a Talos API is unavailable, report the supported UNSUPPORTED result rather than attempting another access path.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
