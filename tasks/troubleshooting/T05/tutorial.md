# T05 Tutorial: Repair a Pod-local DNS fault

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Pod DNS policy `None` bypasses cluster search/resolver setup; DNS policy is immutable.** Compare `kubectl exec -n "$NS" <healthy-pod> -c <resolver> -- cat /etc/resolv.conf` with `dns-stray`. Preserve its image/container/labels from `kubectl get pod dns-stray -n "$NS" -o yaml`; remove server-generated metadata, set `dnsPolicy: ClusterFirst`, remove `dnsConfig`, and keep container unchanged. Because Pod DNS policy is immutable, delete only `dns-stray` and recreate it from the corrected manifest. Verify Running, then `kubectl exec -n "$NS" dns-stray -- nslookup web.$NS.svc.cluster.local`; result should include a Service address. Use actual configured namespace in FQDN. Do not change CoreDNS or leave documentation-only 192.0.2.53 nameserver.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
