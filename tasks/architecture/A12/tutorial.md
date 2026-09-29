# A12 Tutorial: Bootstrap a disposable cluster only

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Bootstrap lifecycle and safety.** This task is intentionally outside Talos. A kubeadm bootstrap requires compatible runtime/kubelet, API reachability, CNI and short-lived join credentials. There is no task scorer performing these host operations.

The procedure below is hands-on only on snapshot-backed Ubuntu/Debian VMs named `cp-sandbox` and `worker-sandbox`. It installs a matching CRI/kubelet/kubeadm/kubectl set, initializes the control plane with a VM-private endpoint and Pod CIDR, installs a compatible CNI, joins the worker with a short-lived token, then checks node readiness and Pod networking. It is not run by the task scorer and is never applicable to Talos or the repository cluster.

## External disposable-VM workflow

This task is unsupported on Talos and does not use the repository cluster. Run commands only inside a fresh, isolated Ubuntu/Debian kubeadm VM console/SSH session: first `cp-sandbox`, later `worker-sandbox`. Confirm `hostname` and private VM IP against your disposable lab inventory. Take a snapshot of both VMs first. If a terminal is on Talos, a Proxmox-managed Talos node, or the homelab host, stop. The user-owned `~/.kube/config` is a sensitive admin credential for this disposable VM only: never copy it to the repository, a host, or the homelab. Do not reuse the homelab kubeconfig.

### A12: bootstrap the pair

Choose supported Kubernetes minor `N`; install matching kubeadm/kubelet/kubectl packages from the corresponding `pkgs.k8s.io` minor repository on both VMs. Use `apt-cache madison` to pick exact package versions. Configure containerd with `SystemdCgroup = true`, disable swap, load `overlay`/`br_netfilter`, and set forwarding sysctls. Example repository/package steps are Ubuntu/Debian-only; set `N_MINOR` and `K8S_DEB_VERSION` deliberately for the disposable OS:

> **STOP — privileged commands below must be run only in both isolated kubeadm VMs. Never run on Talos, Proxmox-managed Talos nodes, or the homelab.**

```bash
# In cp-sandbox/worker-sandbox VM consoles only.
sudo apt-get update
sudo apt-get install -y ca-certificates curl gpg containerd
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${N_MINOR}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
printf 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v%s/deb/ /\n' "$N_MINOR" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
apt-cache madison kubeadm kubelet kubectl
sudo apt-get install -y kubelet="$K8S_DEB_VERSION" kubeadm="$K8S_DEB_VERSION" kubectl="$K8S_DEB_VERSION"
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now containerd kubelet
```

Prepare containerd cgroups, swap, kernel modules, and sysctls on both VMs before initializing. On `cp-sandbox`, use only its private VM-network IP and a Pod CIDR matching chosen CNI (example Flannel network below). Set `K8S_VERSION` to a supported full release `vN.x.y`; do not use a public/homelab API endpoint.

> **STOP — the next privileged command is only for the disposable `cp-sandbox` VM console. Check hostname/IP. It must never be run on a Talos/homelab control plane.**

```bash
# Inside cp-sandbox VM only.
sudo kubeadm init --kubernetes-version "$K8S_VERSION" \\
  --apiserver-advertise-address="$CP_VM_IP" \\
  --control-plane-endpoint="$CP_VM_IP:6443" \\
  --pod-network-cidr=10.244.0.0/16
install -d -m 0700 "$HOME/.kube"
sudo install -o "$(id -u)" -g "$(id -g)" -m 0600 /etc/kubernetes/admin.conf "$HOME/.kube/config"
export KUBECONFIG="$HOME/.kube/config"
```

Choose a Flannel release explicitly documented compatible with `K8S_VERSION` and `10.244.0.0/16`, storing it in `FLANNEL_VERSION`. Before applying, verify the kubeconfig server is only `https://$CP_VM_IP:6443`.

> **STOP — this CNI apply is only from `cp-sandbox` inside the isolated disposable VMs, never from the host or a Talos kubeconfig.**

```bash
# Inside cp-sandbox VM only; KUBECONFIG must be its local admin.conf.
curl -fsSLo /tmp/kube-flannel.yml "https://github.com/flannel-io/flannel/releases/download/${FLANNEL_VERSION}/kube-flannel.yml"
kubectl --kubeconfig="$HOME/.kube/config" apply -f /tmp/kube-flannel.yml
```

Wait for CoreDNS and CNI Pods Ready. In the worker VM, repeat OS/runtime/package prerequisites.

> **STOP — the token/join command sequence applies only to `cp-sandbox` and `worker-sandbox` VM consoles. Never run it on Talos or the homelab. Treat its output as a credential.**

Generate a 15-minute worker join command on cp-sandbox using `sudo kubeadm token create --ttl 15m --print-join-command`; its output is a credential—use only in the worker console and never save it as evidence. Execute the generated command on `worker-sandbox` only.

Verify on the disposable control plane: `kubectl get nodes -o wide` must show one Ready control-plane and one Ready worker; `kubectl get pods -A` must show CNI/CoreDNS Ready. Start a temporary test Pod and Service within this disposable cluster to prove Pod-to-Pod/Service traffic, then remove just those test objects. If bootstrap/network checks fail, revert VM snapshots. These commands do not apply to the practice lab.
