# A13 Tutorial: Upgrade an isolated kubeadm pair only

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Minor upgrades respect skew and preserve rollback.** Upgrade one minor at a time and control plane before worker; snapshot recovery is safer than improvising rollback.

Only for isolated snapshot-backed kubeadm VMs `cp-sandbox` and `worker-sandbox`, record baseline node versions and application response. Select a supported `N+1` release; review the matching kubeadm/kubelet release notes and version-skew policy. Upgrade control plane first, then drain the worker, update its kubelet/runtime packages as required, return it to service, and confirm both nodes at target version and application response. If any check fails, revert VM snapshots. **This is not a Talos procedure: do not run package upgrades, node drains, or kubeadm commands on the homelab.** The commands below are strictly VM-console commands.

## External disposable-VM workflow

A13 is unsupported on Talos and is not an upgrade procedure for the repository cluster. Use only isolated, snapshot-backed Ubuntu/Debian kubeadm VMs `cp-sandbox` and `worker-sandbox`; verify hostname and private IP before every privileged step. If connected to Talos, a Proxmox-managed Talos node, or the homelab, stop. Never point commands at that cluster or copy its kubeconfig into these VMs. Snapshot both VMs before work and immediately before upgrade. The VM admin kubeconfig is a sensitive credential; keep its operator-readable copy only inside `cp-sandbox`, never in the repository, host, or homelab.

### A13: controlled N to N+1 upgrade

Record baseline node versions, component health and workload Service response from the disposable control plane. Read official Kubernetes version-skew policy and select exactly the next supported minor `N+1`; do not skip a minor. Add the `pkgs.k8s.io` repository for target minor to both VMs, use `apt-cache madison` for exact target Debian package versions, and keep kubelet/kubectl at the current version until kubeadm control-plane upgrade instructions say otherwise. Export exact versions as `KUBEADM_DEB_VERSION`, `KUBELET_DEB_VERSION`, `KUBECTL_DEB_VERSION`, and release as `K8S_TARGET=vN+1.x.y`.

> **STOP — the admin kubeconfig copy below is an administrative credential for this disposable cluster only. Run it from the ordinary operator account inside `cp-sandbox`; never copy it to the repository, host, Talos, or homelab.**

```bash
# In cp-sandbox VM as the ordinary operator user (not on the host).
install -d -m 0700 "$HOME/.kube"
sudo install -o "$(id -u)" -g "$(id -g)" -m 0600 /etc/kubernetes/admin.conf "$HOME/.kube/config"
export KUBECONFIG="$HOME/.kube/config"
```

Keep this same ordinary-user shell on `cp-sandbox` for all management commands below; `sudo` is used only for VM package/service/kubeadm operations. The worker never receives this admin kubeconfig.

> **STOP — all privileged package and kubeadm commands below are for `cp-sandbox` VM only. Never run them on Talos, Proxmox-managed Talos nodes, or the homelab. Verify VM hostname/IP and the kubeconfig server is the private disposable API endpoint.**

```bash
# Inside the same ordinary-user cp-sandbox shell; KUBECONFIG is its user-owned copy.
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm="$KUBEADM_DEB_VERSION"
sudo apt-mark hold kubeadm
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply "$K8S_TARGET"
```

After the control-plane upgrade, update client/node binaries from the same target-minor repository. Pin exact package versions chosen from `apt-cache madison`:

> **STOP — these privileged apt commands are only in `cp-sandbox` VM.**

```bash
sudo apt-mark unhold kubectl kubelet
sudo apt-get install -y kubectl="$KUBECTL_DEB_VERSION" kubelet="$KUBELET_DEB_VERSION"
sudo apt-mark hold kubectl kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

Confirm control-plane static Pods and API readiness before moving on. For a single-control-plane lab, follow kubeadm release documentation about scheduling/draining the control plane; never improvise a drain.

> **STOP — the drain command below is only for the worker node in the disposable kubeadm cluster. It must not target any homelab/Talos node. Confirm `$WORKER_NODE` is exactly `worker-sandbox`’s Kubernetes node name.**

```bash
# From the ordinary-user cp-sandbox VM shell with its exported disposable KUBECONFIG.
kubectl drain "$WORKER_NODE" --ignore-daemonsets --delete-emptydir-data
```

> **STOP — package/upgrade commands below are only inside `worker-sandbox` VM console. Never run on a Talos node or homelab worker.**

```bash
# Inside worker-sandbox VM only.
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm="$KUBEADM_DEB_VERSION"
sudo apt-mark hold kubeadm
sudo kubeadm upgrade node
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet="$KUBELET_DEB_VERSION" kubectl="$KUBECTL_DEB_VERSION"
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

> **STOP — uncordon only the same disposable `worker-sandbox` node through cp-sandbox’s kubeconfig.**

```bash
kubectl uncordon "$WORKER_NODE"
kubectl get nodes -o wide
kubectl get pods -A
```

Verify both nodes report target `N+1`, system Pods are Ready, and the same application Service responds. If a version/readiness/network check fails, revert both VM snapshots to pre-upgrade state; Kubernetes does not support an improvised package downgrade. These procedures never apply to this homelab.
