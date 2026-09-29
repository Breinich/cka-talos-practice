# A04 Tutorial: Run a non-API consumer without a token

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Disable unused API credentials.** Pod identity and API token projection are separate controls: assign the existing restricted account but disable automatic token mounting for a process that does not call Kubernetes.

Inspect the seeded ServiceAccount, then create `relay-consumer` as an owned Pod in `$NS`, using `serviceAccountName: relay-identity`, `automountServiceAccountToken: false`, container `busybox:1.36`, and a long-running sleep process. Apply only this namespaced Pod manifest. Verify `kubectl -n "$NS" get pod relay-consumer -o jsonpath='{.spec.serviceAccountName} {.spec.automountServiceAccountToken} {.status.phase}'` shows the expected account, false, Running. Do not alter the ServiceAccount token policy or grant privileges.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
