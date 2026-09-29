# CKA Practice Tasks

Work only in the namespace printed by `setup.sh` (default `cka-practice`). Every object you create must carry `cka-lab.io/owner=cka-talos-practice`; cluster-scoped exercise objects must also carry `cka-lab.io/prefix=cka-practice` (or your chosen prefix). Do not change nodes, `kube-system`, Talos machine configuration, cluster-wide admission, or existing StorageClasses. Save command evidence requested below as plain text in `.lab/evidence/<ID>.txt`; never put tokens, keys, or Secret values there. Names and measurable end states are intentional validator contracts.

Modes: **live** is namespace-scoped; **conditional** is scored only when setup detects support; **read-only** permits observation but no mutation; **simulation** is a local artifact; **disposable-kubeadm** must not be attempted on Talos and is always reported `UNSUPPORTED` here.

## Cluster Architecture, Installation and Configuration (A)

- **A01 — live (2):** Record `kubectl version` and two API discovery commands, including short names and namespaced scope, in `A01.txt`.
- **A02 — live (3):** Create `.lab/evidence/A02.kubeconfig`, limited to this cluster/context and an identity that can get Pods in the lab namespace. Use a short-lived ServiceAccount token; do not copy an administrator credential. Verify it.
- **A03 — live (3):** Create ServiceAccount `exam-sa`, Role `pod-reader` (get/list/watch Pods only), and a RoleBinding connecting them.
- **A04 — live (2):** Run Pod `sa-consumer` as `exam-sa`; disable automatic token mounting unless the container genuinely needs the API.
- **A05 — live (2):** Use `kubectl auth can-i` with impersonation to demonstrate one allowed and one denied action for `exam-sa`; save only yes/no commands and results in `A05.txt`.
- **A06 — live (2):** Discover CRD resources and inspect one installed CRD's group, scope and versions without changing it. Save sanitized output in `A06.txt`.
- **A07 — simulation, requires Helm (2):** Without installing anything, use `helm template` on a locally chosen or already downloaded chart. Save output as `A07-rendered.yaml` and identify values/release/namespace flags. If Helm is absent this is `UNSUPPORTED`.
- **A08 — live (2):** Build from `fixtures/kustomize/base` using an overlay that adds prefix `exam-`, namespace, ownership label, and two replicas. Apply so Deployment `exam-kustom-app` exists.
- **A09 — read-only (2):** Identify API server, scheduler, controller manager, and etcd instances and their placement; save commands/output in `A09.txt`. Do not edit static pods.
- **A10 — read-only, Talos (2):** With `talosctl`, inspect service health for kubelet/containerd and machine health; save non-secret output in `A10.txt`. Do not use `talosctl apply-config`, reboot, reset, or service restart.
- **A11 — simulation (3):** Write `A11.txt` containing a safe Talos etcd snapshot/restore runbook: endpoint selection, quorum assumptions, snapshot protection, verification, restore preconditions, and rollback. Do not execute it.
- **A12 — disposable-kubeadm (3):** On separate throwaway VMs only, prepare runtime/sysctls, run `kubeadm init`, install CNI, generate a join command, and join a worker. **Unsupported and prohibited on Talos.**
- **A13 — disposable-kubeadm (3):** On a snapshot-backed kubeadm lab only, plan and execute one-minor control-plane then worker upgrade, respecting skew, drain/uncordon, package holds, and `kubeadm upgrade`. **Unsupported and prohibited on Talos.**
- **A14 — read-only (2):** Inspect the Kubernetes API certificate presented by the configured server and/or Talos certificate status; record issuer and expiry evidence in `A14.txt`. Never copy private keys.
- **A15 — read-only (2):** Inspect configured admission webhooks and Pod Security namespace labels/policy behavior. Record APIs and observed enforcement in `A15.txt`; do not modify webhooks or shared namespace labels.

## Workloads and Scheduling (W)

- **W01 — live (2):** Create Deployment `resource-app` with CPU/memory requests and limits, two replicas, and the ownership label.
- **W02 — live (2):** Create/update Deployment `rollout-app` with RollingUpdate strategy, then change its image and watch rollout status.
- **W03 — live (2):** Introduce a bad revision in `rollout-app`, identify it, roll back, and leave the Deployment healthy with revision history.
- **W04 — live (2):** Create completing Job `one-shot` and suspended CronJob `periodic` with a valid schedule and safe history limits.
- **W05 — live (2):** Create DaemonSet `node-agent` that can run on worker nodes without adding or removing node taints. Keep resource requests tiny.
- **W06 — live (2):** Create headless Service and StatefulSet, both `ordered-app`, with stable network identity and at least two replicas. Do not require persistent storage.
- **W07 — live (2):** Create ConfigMap `app-config`, Secret `app-secret` with a dummy value, and Pod `config-consumer` consuming both via environment and/or volumes. Do not expose decoded Secret data.
- **W08 — live (2):** Create Deployment `affinity-app` using required or preferred node affinity plus preferred pod anti-affinity. It must remain schedulable on this cluster.
- **W09 — live (2):** Without changing node taints, create Pod `tolerant-app` with a meaningful toleration and record the matching taint/NoSchedule reasoning in `W09.txt`.
- **W10 — conditional metrics (2):** Create HPA `web-hpa` targeting Deployment `web`, CPU utilization, minimum 1 and maximum at least 2 replicas.
- **W11 — live (2):** Create Pod `hardened-app` with readiness/startup or liveness probes, non-root execution where image-compatible, and `allowPrivilegeEscalation: false`.
- **W12 — live (2):** Create Pod `composed-app` with an init container and a long-running container named `sidecar` sharing an `emptyDir` with the main container.
- **W13 — live (2):** Create PodDisruptionBudget `resource-app` selecting W01 and preserving at least one available replica; explain voluntary versus involuntary disruption in `W13.txt`. Do not drain a node to test it.

## Services and Networking (N)

- **N01 — live (2):** Create a backing Deployment and ClusterIP Service `app-service`; named ports and selectors must yield ready EndpointSlice addresses.
- **N02 — live (2):** Create headless Service `ordered-headless`, verify per-pod DNS, and save lookup output in `N02.txt`.
- **N03 — live (2):** Use labels/selectors and EndpointSlice inspection to map `web` Service traffic to Pods; record addresses and reasoning in `N03.txt`.
- **N04 — live (2):** From `toolbox`, test short, namespace-qualified, and cluster-qualified Service DNS names. Save names and returned addresses in `N04.txt`.
- **N05 — conditional NetworkPolicy (3):** Only if setup reports enforcement support, create `default-deny` ingress/egress policy and least-privilege `allow-web`; verify allowed and denied flows. Do not assume API presence proves enforcement.
- **N06 — conditional Ingress (2):** If an IngressClass exists, create `web-ingress` routing a test hostname/path to `web`; do not alter controller configuration or public DNS.
- **N07 — conditional Gateway API (2):** If Gateway CRDs and a usable Gateway exist, attach HTTPRoute `web-route` to an allowed listener and route to `web`. Do not create a cluster-scoped GatewayClass.
- **N08 — live (2):** Create Service `port-fixed` selecting `web`; first diagnose a wrong target port, then leave named `targetPort: http` with populated EndpointSlices.
- **N09 — read-only (2):** Identify the installed CNI and whether kube-proxy, eBPF, iptables, or IPVS implements Service forwarding. Save evidence in `N09.txt`; do not restart agents.
- **N10 — live (1):** Port-forward `web` locally, fetch it, stop the forward, and record the command plus successful HTTP evidence in `N10.txt`.
- **N11 — simulation (2):** Write `.lab/evidence/N11-services.yaml` containing valid, ownership-labelled NodePort and ExternalName Service examples, and client-dry-run them. Do not apply them: NodePort can expose a homelab workload and a LoadBalancer can allocate shared infrastructure.

## Storage (S)

- **S01 — live (2):** Create Pod `scratch-app` that writes then reads data through a mounted `emptyDir`.
- **S02 — Talos simulation (3):** Write `.lab/evidence/S02-static.yaml` containing a valid, explicitly bound static PV plus PVC `static-claim` and a consuming Pod. Label the PV with lab ownership and active prefix, then client-dry-run the file but do not apply it. Talos has no assumed safe node path or static backend; practice live binding only in a disposable lab with a known-empty volume.
- **S03 — conditional default StorageClass (2):** If detected, create `dynamic-claim` using the default class and verify it becomes Bound after use. Do not modify the class.
- **S04 — read-only (2):** Inspect StorageClasses, default selection, reclaim/binding/expansion settings, CSIDrivers and provisioners. Save in `S04.txt`.
- **S05 — live (2):** Only when a detected class advertises expansion, create `expandable-claim`, request a safe size increase, verify capacity/filesystem behavior, and record it in `S05.txt`. Otherwise document the unsupported reason; never shrink a claim.
- **S06 — live/read-only (2):** Compare access modes and reclaim policies of available or lab-created volumes and record consequences in `S06.txt`. Do not change shared PVs.

## Troubleshooting (T)

- **T01 — live (2):** Diagnose and repair `broken-image`; leave its rollout healthy without recreating the Deployment.
- **T02 — live (2):** Diagnose and repair the readiness configuration on `broken-ready`; leave it Available.
- **T03 — live (2):** Use scheduler events to diagnose Pod `unschedulable`; remove only its impossible selector and leave it Running. Never relabel a node.
- **T04 — live (2):** Repair `broken-service` so it selects `web` Pods and has ready endpoints.
- **T05 — live (2):** Diagnose Service DNS from `toolbox`, including `/etc/resolv.conf` and `kubernetes.default`; save commands/output in `T05.txt`.
- **T06 — live (2):** In a disposable lab Pod, generate current and previous container logs and demonstrate `kubectl logs` selection in `T06.txt`.
- **T07 — live (2):** Use `describe`, sorted events, reasons and messages to explain one seeded failure before fixing it; save evidence in `T07.txt`.
- **T08 — conditional metrics (2):** Use `kubectl top` for nodes and namespaced Pods, identify CPU and memory units, and save sanitized output in `T08.txt`.
- **T09 — read-only (2):** Assess all node conditions, taints, capacity/allocatable and pressure signals in `T09.txt`. Do not drain, cordon or label nodes.
- **T10 — read-only, Talos (2):** Use Talos read-only service/log/process commands to inspect kubelet and containerd/CRI health; save in `T10.txt`. No restarts.
- **T11 — read-only, Talos (3):** Correlate Kubernetes and Talos evidence for API server, scheduler/controller and etcd member health in `T11.txt`. Do not mutate quorum or static pod configuration.
- **T12 — live (2):** Use `kubectl debug` with an ephemeral container against a lab Pod, inspect shared network/process context, exit, and save the command plus observation in `T12.txt`. Do not target host namespaces or nodes.
