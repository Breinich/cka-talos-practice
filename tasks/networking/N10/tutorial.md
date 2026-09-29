# N10 Tutorial: Check the repaired service through a local tunnel

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Port-forward tests Service routing locally without public exposure.** Check seeded `estuary-front` selector/endpoints are ready before tunnel. Run `kubectl -n "$NS" port-forward service/estuary-front 18080:8080`, in another shell request `curl -sS -o /tmp/body -w '%{http_code}' http://127.0.0.1:18080/`, then stop the forward with Ctrl-C. Record namespace, service, localPort=18080, remotePort=8080, actual HTTP status and body in N10-forward.json; do not include credentials. Verify success response and live ready endpoint. No NodePort/public listener; tunnel process must be stopped.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
