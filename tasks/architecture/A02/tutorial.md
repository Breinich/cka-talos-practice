# A02 Tutorial: Scope a temporary client identity

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**ServiceAccount tokens and kubeconfig structure.** A kubeconfig can contain one narrowly scoped user/context without copying administrator credentials. The seeded Role permits only Pod get.

Inspect `relay-identity`, its Role/RoleBinding, and current cluster endpoint/CA metadata. Turn off shell tracing, then capture a short-lived token without printing it: `TOKEN=$(kubectl create token relay-identity -n "$NS" --duration=10m)`. Read current cluster fields with `SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')` and `CA_DATA=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')`. Use `umask 077`, then construct the file with a here-document (keep shell tracing disabled):

```bash
cat > "$LAB/evidence/A02.kubeconfig" <<EOF
apiVersion: v1
kind: Config
clusters:
- name: lab
  cluster:
    server: ${SERVER}
    certificate-authority-data: ${CA_DATA}
users:
- name: relay-identity
  user:
    token: ${TOKEN}
contexts:
- name: relay-reader
  context:
    cluster: lab
    user: relay-identity
    namespace: ${NS}
current-context: relay-reader
EOF
```

 Finally `chmod 600 "$LAB/evidence/A02.kubeconfig"`. Validate `KUBECONFIG=... kubectl auth can-i get pods -n "$NS"` (yes), then `... can-i delete pods -n "$NS"` (no), and `kubectl --kubeconfig=... get pod toolbox -n "$NS"`. Score within token lifetime. Never echo token, write it into task logs, use `config view --raw`, or include admin auth.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/A02/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/architecture/A02/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
