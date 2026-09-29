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
| [A01](tasks/architecture/A01.md) | Discover API resources and cluster version |
| [A02](tasks/architecture/A02.md) | Build and use a minimal kubeconfig |
| [A03](tasks/architecture/A03.md) | Create namespace Role and RoleBinding |
| [A04](tasks/architecture/A04.md) | Configure a ServiceAccount |
| [A05](tasks/architecture/A05.md) | Test RBAC authorization |
| [A06](tasks/architecture/A06.md) | Inspect CRDs and API discovery |
| [A07](tasks/architecture/A07.md) | Render and inspect a Helm release |
| [A08](tasks/architecture/A08.md) | Build a Kustomize overlay |
| [A09](tasks/architecture/A09.md) | Inspect control-plane components |
| [A10](tasks/architecture/A10.md) | Inspect Talos machine and service health |
| [A11](tasks/architecture/A11.md) | Plan an etcd snapshot and restore |
| [A12](tasks/architecture/A12.md) | Practice kubeadm init and worker join |
| [A13](tasks/architecture/A13.md) | Practice a Kubernetes version upgrade |
| [A14](tasks/architecture/A14.md) | Inspect certificate lifetimes |
| [A15](tasks/architecture/A15.md) | Inspect admission and Pod Security controls |
| [A16](tasks/architecture/A16.md) | Model an operator lifecycle safely |
| [A17](tasks/architecture/A17.md) | Plan a highly available Talos control plane |
| [A18](tasks/architecture/A18.md) | Render a cluster component with Helm or Kustomize |

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
| [N01](tasks/networking/N01.md) | Expose a Deployment with ClusterIP |
| [N02](tasks/networking/N02.md) | Create and test a headless Service |
| [N03](tasks/networking/N03.md) | Inspect EndpointSlices and selectors |
| [N04](tasks/networking/N04.md) | Validate cluster DNS |
| [N05](tasks/networking/N05.md) | Enforce default deny and allow rules |
| [N06](tasks/networking/N06.md) | Create an Ingress rule |
| [N07](tasks/networking/N07.md) | Create Gateway API routing |
| [N08](tasks/networking/N08.md) | Diagnose Service port and targetPort |
| [N09](tasks/networking/N09.md) | Inspect CNI and kube-proxy replacement |
| [N10](tasks/networking/N10.md) | Use port-forward for local access |
| [N11](tasks/networking/N11.md) | Compare Service types safely |

## Storage

| ID | Task |
|---|---|
| [S01](tasks/storage/S01.md) | Create and mount emptyDir |
| [S02](tasks/storage/S02.md) | Model a static PV and PVC safely |
| [S03](tasks/storage/S03.md) | Provision a dynamic PVC |
| [S04](tasks/storage/S04.md) | Inspect StorageClasses and CSI drivers |
| [S05](tasks/storage/S05.md) | Expand and verify a volume claim |
| [S06](tasks/storage/S06.md) | Use access modes and reclaim policy |

## Troubleshooting

| ID | Task |
|---|---|
| [T01](tasks/troubleshooting/T01.md) | Repair a broken Deployment image |
| [T02](tasks/troubleshooting/T02.md) | Repair failed readiness |
| [T03](tasks/troubleshooting/T03.md) | Repair an unschedulable Pod |
| [T04](tasks/troubleshooting/T04.md) | Repair Service routing |
| [T05](tasks/troubleshooting/T05.md) | Diagnose DNS from a Pod |
| [T06](tasks/troubleshooting/T06.md) | Use logs and previous logs |
| [T07](tasks/troubleshooting/T07.md) | Use events and describe |
| [T08](tasks/troubleshooting/T08.md) | Inspect resource usage |
| [T09](tasks/troubleshooting/T09.md) | Assess node conditions and capacity |
| [T10](tasks/troubleshooting/T10.md) | Inspect container runtime and kubelet |
| [T11](tasks/troubleshooting/T11.md) | Diagnose control-plane and etcd health |
| [T12](tasks/troubleshooting/T12.md) | Debug with an ephemeral container |
