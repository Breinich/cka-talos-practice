# N09 Tutorial: Triage a DNS timeout without editing CoreDNS

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**CoreDNS serving a zone does not imply client packets can reach DNS.** Read both `resources/coredns.txt` and dns.json. Corefile serves cluster.local and forwards external names; the simulated query is cluster FQDN via UDP/53, but egress permits only TCP/53. Thus identify UDP/53 blocked at client policy and choose `client-egress-policy`, not CoreDNS Corefile. Write exact plugin/zone/name/blockedTransport/blockedPort/repairScope to N09-incident.json. Verify source says `kubernetes cluster.local` and egress mismatch. Do not inspect/edit live CoreDNS or CNI.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
