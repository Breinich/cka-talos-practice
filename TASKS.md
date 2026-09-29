# CKA Practice Task Index

Tasks are organized by the five current CKA pillars. Each task file contains its explicit ID, points, capability/mode, safety boundary, prompt, and one-task validation commands. Global rules:

- Work only in the namespace printed by `setup.sh` (default `cka-practice`).
- Label created objects `cka-lab.io/owner=cka-talos-practice`; cluster-scoped exercise objects also need the active `cka-lab.io/prefix` label.
- Save requested evidence under `.lab/evidence/<ID>.*` without tokens, private keys, Secret values, or unrelated cluster data.
- **Live** tasks are namespace-scoped; **conditional** tasks require a detected capability; **read-only** tasks forbid mutation; **simulation** tasks create local artifacts; **disposable-kubeadm** tasks must never run on Talos.
- Validate one task with `./scripts/validate.sh --task ID`; validate all tasks with `./scripts/validate.sh`.

## Cluster Architecture, Installation and Configuration

| ID | Task |
|---|---|
| [A01](tasks/architecture/A01.md) | Read the live discovery surface |
| [A02](tasks/architecture/A02.md) | Scope a temporary client identity |
| [A03](tasks/architecture/A03.md) | Repair a restricted reader |
| [A04](tasks/architecture/A04.md) | Run a non-API consumer without a token |
| [A05](tasks/architecture/A05.md) | Check both sides of the permission boundary |
| [A06](tasks/architecture/A06.md) | Classify an uninstalled API extension |
| [A07](tasks/architecture/A07.md) | Render a local release without installing it |
| [A08](tasks/architecture/A08.md) | Promote a local overlay into the lab |
| [A09](tasks/architecture/A09.md) | Locate control-plane services without host access |
| [A10](tasks/architecture/A10.md) | Triage Talos services without repair |
| [A11](tasks/architecture/A11.md) | Decide whether restore is permitted |
| [A12](tasks/architecture/A12.md) | Bootstrap a disposable cluster only |
| [A13](tasks/architecture/A13.md) | Upgrade an isolated kubeadm pair only |
| [A14](tasks/architecture/A14.md) | Check the API serving certificate |
| [A15](tasks/architecture/A15.md) | Inventory admission without changing it |
| [A16](tasks/architecture/A16.md) | Model an operator install offline |
| [A17](tasks/architecture/A17.md) | Assess one failure before expanding HA |
| [A18](tasks/architecture/A18.md) | Render a component overlay offline |

## Workloads and Scheduling

| ID | Task |
|---|---|
| [W01](tasks/workloads/W01.md) | Create a Deployment with resources |
| [W02](tasks/workloads/W02.md) | Perform and inspect a rolling update |
| [W03](tasks/workloads/W03.md) | Roll back a Deployment |
| [W04](tasks/workloads/W04.md) | Create a Job and CronJob |
| [W05](tasks/workloads/W05.md) | Create a node-spanning DaemonSet |
| [W06](tasks/workloads/W06.md) | Create a StatefulSet with stable identity |
| [W07](tasks/workloads/W07.md) | Use ConfigMap and Secret projections |
| [W08](tasks/workloads/W08.md) | Apply node affinity and pod anti-affinity |
| [W09](tasks/workloads/W09.md) | Use taints and tolerations safely |
| [W10](tasks/workloads/W10.md) | Configure an HPA |
| [W11](tasks/workloads/W11.md) | Use probes and security context |
| [W12](tasks/workloads/W12.md) | Use init and sidecar containers |
| [W13](tasks/workloads/W13.md) | Protect availability during disruptions |

## Services and Networking

| ID | Task |
|---|---|
| [N01](tasks/networking/N01.md) | Repair the front door |
| [N02](tasks/networking/N02.md) | Publish a headless peer list |
| [N03](tasks/networking/N03.md) | Recover a missing catalog endpoint |
| [N04](tasks/networking/N04.md) | Resolve a search-path incident offline |
| [N05](tasks/networking/N05.md) | Design isolated client egress offline |
| [N06](tasks/networking/N06.md) | Draft the legacy entrypoint offline |
| [N07](tasks/networking/N07.md) | Translate the entrypoint into header routing |
| [N08](tasks/networking/N08.md) | Repair an incorrect backend port |
| [N09](tasks/networking/N09.md) | Triage a DNS timeout without editing CoreDNS |
| [N10](tasks/networking/N10.md) | Check the repaired service through a local tunnel |
| [N11](tasks/networking/N11.md) | Model two service exposures without applying them |

## Storage

| ID | Task |
|---|---|
| [S01](tasks/storage/S01.md) | Restore the shared workspace |
| [S02](tasks/storage/S02.md) | Repair an offline archive binding |
| [S03](tasks/storage/S03.md) | Bind a disposable data claim |
| [S04](tasks/storage/S04.md) | Inventory storage without mutating it |
| [S05](tasks/storage/S05.md) | Grow a bound disposable claim |
| [S06](tasks/storage/S06.md) | Protect an offline records volume |

## Troubleshooting

| ID | Task |
|---|---|
| [T01](tasks/troubleshooting/T01.md) | Recover the image pipeline |
| [T02](tasks/troubleshooting/T02.md) | Restore the admission probe |
| [T03](tasks/troubleshooting/T03.md) | Clear a scheduling dead end |
| [T04](tasks/troubleshooting/T04.md) | Reconnect a Service to its backends |
| [T05](tasks/troubleshooting/T05.md) | Repair a Pod-local DNS fault |
| [T06](tasks/troubleshooting/T06.md) | Capture the failed attempt before repair |
| [T07](tasks/troubleshooting/T07.md) | Rank eviction candidates offline |
| [T08](tasks/troubleshooting/T08.md) | Read a metrics snapshot |
| [T09](tasks/troubleshooting/T09.md) | Build a node pressure inventory |
| [T10](tasks/troubleshooting/T10.md) | Trace kubelet to its runtime |
| [T11](tasks/troubleshooting/T11.md) | Correlate control-plane signals |
| [T12](tasks/troubleshooting/T12.md) | Inspect Pod namespaces without host access |
