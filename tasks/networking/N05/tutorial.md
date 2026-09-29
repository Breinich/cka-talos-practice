# N05 Tutorial: Design isolated client egress offline

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**NetworkPolicy egress isolation is additive: selecting a Pod isolates it, then allow rules union together.** Offline only. Write two policies to N05-policy.yaml. Both `podSelector.matchLabels` must include `app: toolbox` and owner label; `policyTypes: [Egress]`. Deny policy selects the client and has no egress rules. Allow policy contains exactly two rules: UDP port 53 to namespaceSelector `kubernetes.io/metadata.name: kube-system`; TCP port 80 to same-namespace Pods `app: estuary-api` AND owner label (one `to` peer with podSelector). Both owned and namespace `$NS`. The core `spec` structure is:

```yaml
# deny policy
spec:
  podSelector:
    matchLabels: {app: toolbox, cka-lab.io/owner: cka-talos-practice}
  policyTypes: [Egress]
  # no egress list: all selected-Pod egress denied
---
# allow policy
spec:
  podSelector:
    matchLabels: {app: toolbox, cka-lab.io/owner: cka-talos-practice}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: kube-system}
    ports: [{protocol: UDP, port: 53}]
  - to:
    - podSelector:
        matchLabels: {app: estuary-api, cka-lab.io/owner: cka-talos-practice}
    ports: [{protocol: TCP, port: 80}]
```

Wrap each spec in its own `networking.k8s.io/v1` NetworkPolicy document with exact names and namespace. Confirm DNS UDP/53 and API TCP/80 only; no blanket allow, no TCP DNS substitution, and no apply since enforcement is not modeled.

## Task-scoped setup, verification, and cleanup

Set `NS` to the configured task namespace and `LAB` to this task's evidence root (`.lab/N05/$NS` for namespaced live tasks, or the path given in the procedure for offline/read-only exercises). Use the task's own setup only when the mode requires it; setup creates/seeds this task's isolated scope. Inspect the exact object/resource before mutation, apply only the fields described above, then inspect controller status and run `./tasks/networking/N05/score.sh` (add `--json` for criterion detail). For offline simulations use local parser/client dry-run only; never apply synthetic data. If the task is conditional and its capability gate is false, stop with SKIP rather than installing a controller, metrics server, storage backend, or debug capability. Cleanup only via this task's lifecycle after data review; persistent claims may intentionally block teardown.

**Safety:** do not broaden namespace scope, expose credentials, or mutate nodes, cluster-scoped resources, Talos config, etcd, or a homelab. A12/A13 operations are only for disposable snapshot-backed VMs; the guides intentionally give no copy-paste bootstrap/upgrade command sequence for Talos.
