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

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
