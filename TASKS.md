# CKA Practice Task Index

Tasks are organized by the five current CKA pillars. Each task file contains its explicit ID, points, capability/mode, safety boundary, prompt, and one-task validation commands. Global rules:

- Run `tasks/<pillar>/<ID>/setup.sh` and work only in its printed namespace (default `cka-practice-<lowercase-id>`). Offline and read-only tasks create no namespace.
- Label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=<ID>`; never apply offline cluster-scoped samples.
- Save evidence under `.lab/<ID>/<namespace>/evidence/` (A02 is the one intentionally short-lived credential; keep mode 0600). Never commit credentials or unrelated cluster data.
- **Live** tasks are namespace-scoped; **conditional** tasks require a detected capability; **read-only** tasks forbid mutation; **simulation** tasks create local artifacts; **disposable-kubeadm** tasks must never run on Talos. A15 is isolated and live.
- Score one task using `tasks/<pillar>/<ID>/score.sh` or `./scripts/score.sh ID`. Teardown uses the matching task wrapper.

## Cluster Architecture, Installation and Configuration

| ID | Task |
|---|---|
| [A01](tasks/architecture/A01/task.md) | Read the live discovery surface |
| [A02](tasks/architecture/A02/task.md) | Scope a temporary client identity |
| [A03](tasks/architecture/A03/task.md) | Repair a restricted reader |
| [A04](tasks/architecture/A04/task.md) | Run a non-API consumer without a token |
| [A05](tasks/architecture/A05/task.md) | Check both sides of the permission boundary |
| [A06](tasks/architecture/A06/task.md) | Classify an uninstalled API extension |
| [A07](tasks/architecture/A07/task.md) | Render a local release without installing it |
| [A08](tasks/architecture/A08/task.md) | Promote a local overlay into the lab |
| [A09](tasks/architecture/A09/task.md) | Locate control-plane services without host access |
| [A10](tasks/architecture/A10/task.md) | Triage Talos services without repair |
| [A11](tasks/architecture/A11/task.md) | Decide whether restore is permitted |
| [A12](tasks/architecture/A12/task.md) | Bootstrap a disposable cluster only |
| [A13](tasks/architecture/A13/task.md) | Upgrade an isolated kubeadm pair only |
| [A14](tasks/architecture/A14/task.md) | Check the API serving certificate |
| [A15](tasks/architecture/A15/task.md) | Inventory admission without changing it |
| [A16](tasks/architecture/A16/task.md) | Model an operator install offline |
| [A17](tasks/architecture/A17/task.md) | Assess one failure before expanding HA |
| [A18](tasks/architecture/A18/task.md) | Render a component overlay offline |

## Workloads and Scheduling

| ID | Task |
|---|---|
| [W01](tasks/workloads/W01/task.md) | Create a Deployment with resources |
| [W02](tasks/workloads/W02/task.md) | Perform and inspect a rolling update |
| [W03](tasks/workloads/W03/task.md) | Roll back a Deployment |
| [W04](tasks/workloads/W04/task.md) | Create a Job and CronJob |
| [W05](tasks/workloads/W05/task.md) | Create a node-spanning DaemonSet |
| [W06](tasks/workloads/W06/task.md) | Create a StatefulSet with stable identity |
| [W07](tasks/workloads/W07/task.md) | Use ConfigMap and Secret projections |
| [W08](tasks/workloads/W08/task.md) | Apply node affinity and pod anti-affinity |
| [W09](tasks/workloads/W09/task.md) | Use taints and tolerations safely |
| [W10](tasks/workloads/W10/task.md) | Configure an HPA |
| [W11](tasks/workloads/W11/task.md) | Use probes and security context |
| [W12](tasks/workloads/W12/task.md) | Use init and sidecar containers |
| [W13](tasks/workloads/W13/task.md) | Protect availability during disruptions |

## Services and Networking

| ID | Task |
|---|---|
| [N01](tasks/networking/N01/task.md) | Repair the front door |
| [N02](tasks/networking/N02/task.md) | Publish a headless peer list |
| [N03](tasks/networking/N03/task.md) | Recover a missing catalog endpoint |
| [N04](tasks/networking/N04/task.md) | Resolve a search-path incident offline |
| [N05](tasks/networking/N05/task.md) | Design isolated client egress offline |
| [N06](tasks/networking/N06/task.md) | Draft the legacy entrypoint offline |
| [N07](tasks/networking/N07/task.md) | Translate the entrypoint into header routing |
| [N08](tasks/networking/N08/task.md) | Repair an incorrect backend port |
| [N09](tasks/networking/N09/task.md) | Triage a DNS timeout without editing CoreDNS |
| [N10](tasks/networking/N10/task.md) | Check the repaired service through a local tunnel |
| [N11](tasks/networking/N11/task.md) | Model two service exposures without applying them |

## Storage

| ID | Task |
|---|---|
| [S01](tasks/storage/S01/task.md) | Restore the shared workspace |
| [S02](tasks/storage/S02/task.md) | Repair an offline archive binding |
| [S03](tasks/storage/S03/task.md) | Bind a disposable data claim |
| [S04](tasks/storage/S04/task.md) | Inventory storage without mutating it |
| [S05](tasks/storage/S05/task.md) | Grow a bound disposable claim |
| [S06](tasks/storage/S06/task.md) | Protect an offline records volume |

## Troubleshooting

| ID | Task |
|---|---|
| [T01](tasks/troubleshooting/T01/task.md) | Recover the image pipeline |
| [T02](tasks/troubleshooting/T02/task.md) | Restore the admission probe |
| [T03](tasks/troubleshooting/T03/task.md) | Clear a scheduling dead end |
| [T04](tasks/troubleshooting/T04/task.md) | Reconnect a Service to its backends |
| [T05](tasks/troubleshooting/T05/task.md) | Repair a Pod-local DNS fault |
| [T06](tasks/troubleshooting/T06/task.md) | Capture the failed attempt before repair |
| [T07](tasks/troubleshooting/T07/task.md) | Rank eviction candidates offline |
| [T08](tasks/troubleshooting/T08/task.md) | Read a metrics snapshot |
| [T09](tasks/troubleshooting/T09/task.md) | Build a node pressure inventory |
| [T10](tasks/troubleshooting/T10/task.md) | Trace kubelet to its runtime |
| [T11](tasks/troubleshooting/T11/task.md) | Correlate control-plane signals |
| [T12](tasks/troubleshooting/T12/task.md) | Inspect Pod namespaces without host access |
