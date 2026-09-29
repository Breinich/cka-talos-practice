# W11 Tutorial: Use probes and security context

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Probes gate readiness/liveness; securityContext reduces container privilege.** Create owned Pod `ember-guard` with container busybox:1.36 running foreground `httpd -f -p 8080`, container `runAsUser: 10001` and `allowPrivilegeEscalation: false`. Add both `readinessProbe` and `livenessProbe` as `tcpSocket.port: 8080` (reasonable initial delay/period), expose containerPort 8080 if desired. Apply only in `$NS`. Check Pod Ready and inspect probe events with `kubectl describe pod ember-guard -n "$NS"`. Port 8080 avoids privileged port restrictions; do not put securityContext only at Pod level if scorer requires container-level field.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
