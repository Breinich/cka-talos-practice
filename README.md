# Safe CKA practice for Talos Kubernetes

A namespace-scoped, self-scoring practice bank for the five current CKA domains, designed for the existing Kubernetes v1.35 Talos cluster whose expected context is `admin@lake`. It contains 57 tasks and deliberately does **not** make changes when cloned or tested.

> This repository is not an installer and no script is automatically run. Review every command. Never point practice tooling at a production context.

## Prerequisites

Required: Bash 4+, `kubectl`, `sed`, `grep`, `awk`, and a reachable Kubernetes API. Your identity needs to create namespaced exercise resources and, for the optional static-PV/RBAC exercises, only the narrowly requested cluster-scoped resources. Optional: `talosctl` for read-only Talos tasks and `helm` for local rendering. Metrics Server, a NetworkPolicy-enforcing CNI, an Ingress controller, Gateway API, and dynamic storage are detected, not assumed. Helm and Gateway API are known to be absent initially, and no default StorageClass is assumed.

Before setup:

```bash
kubectl config current-context       # expected: admin@lake
kubectl cluster-info
make test                            # static only; no cluster mutation
```

## Safety model

- Default namespace/prefix: `cka-practice`; all fixtures use label `cka-lab.io/owner=cka-talos-practice`.
- Setup rejects an existing unowned namespace, suspicious context names, and contexts other than `admin@lake` unless the operator explicitly supplies `--yes`.
- Setup changes no node, Talos machine configuration, `kube-system` object, admission setting, installed controller, StorageClass, CRD, PV, or shared workload. It only creates/reconciles labelled resources in the lab namespace.
- `--yes` confirms context choice; it does not broaden scope or bypass ownership checks.
- Capability checks are conservative. NetworkPolicy is enabled only when the API plus a recognized enforcing CNI are visible. Conditional tasks become `SKIP`, not failures, when absent.
- Read-only Talos tasks prohibit apply-config, reset, reboot, service restarts and quorum changes. Kubeadm lifecycle tasks are explicitly unsupported here.
- Teardown verifies namespace ownership before deletion and removes only lab-labelled cluster-scoped PV/RBAC exercise objects. Never add the ownership label to unrelated resources.
- `.lab/state.env` and mode-0600 `before.yaml` record the original namespace state. No credentials should be placed in evidence except the intentionally short-lived A02 kubeconfig.

## Usage

```bash
./scripts/setup.sh                 # safe on the expected context
# On another intentionally selected disposable context only:
./scripts/setup.sh --yes

less TASKS.md
./scripts/validate.sh --task W01
./scripts/validate.sh --task W01 --json
./scripts/validate.sh              # all tasks, human summary
./scripts/validate.sh --json       # all tasks, machine summary
```

Override scope with `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` or setup flags. The namespace must equal or begin with the prefix. Keep evidence under `.lab/evidence/`; it is gitignored. Validators are read-only, deterministic, and print only criterion counts—not answers. Solution notes live separately in `answers/`.

`make setup`, `make score`, `make teardown`, and `make restore` are convenience equivalents. Setup is idempotent: rerunning it restores only seeded fixtures and retains the original pre-setup backup.

## Scoring

Task weights are in `metadata/tasks.tsv` (121 total configured points before capability exclusions). Each task has two independently checked criteria and can receive partial points. `PASS`, `PARTIAL`, and `FAIL` apply only to supported tasks. `SKIP` means a detected optional API/controller/capability is unavailable. `UNSUPPORTED` means the exercise belongs in a disposable kubeadm environment or a required local tool is missing. Skipped/unsupported points are excluded from the denominator. A nonzero scorer exit means not all applicable points were earned; JSON remains available for automation.

The scorer checks end state or sanitized evidence; it never repairs resources and does not emit full commands or solutions. Some evidence checks establish that the requested diagnostic concepts were recorded, not that every conclusion is semantically correct—review those manually against `answers/`.

## Reset, teardown, and restore

```bash
./scripts/reset.sh --yes       # delete owned lab scope, wait, and seed it again
./scripts/teardown.sh          # remove lab-owned namespace and labelled cluster objects
./scripts/restore.sh           # return to the state captured before first setup
```

Normally the namespace did not exist, so restore is equivalent to safe teardown. If an already lab-owned namespace existed, restore removes current labelled lab objects and reapplies the saved manifest. The backup remains for audit. Namespace deletion is asynchronous. Review `.lab/state.env` and `.lab/before.yaml` before recovery if setup was interrupted. Never manually edit `state.env`.

## Task map

| Current CKA domain | IDs | Tasks | Coverage |
|---|---:|---:|---|
| Cluster Architecture, Installation & Configuration | A01–A15 | 15 | API discovery, kubeconfig, RBAC, ServiceAccounts, CRDs, Helm, Kustomize, admission, control plane, Talos, etcd, certificates, kubeadm install/join/upgrade |
| Workloads & Scheduling | W01–W13 | 13 | resources, rollout/rollback, Jobs/CronJobs, DaemonSets, StatefulSets, configuration, affinity, taints, HPA, probes/security, init/sidecars, disruption budgets |
| Services & Networking | N01–N11 | 11 | Services, DNS, EndpointSlices, policies, Ingress, Gateway API, Service types, CNI/service routing, port-forward |
| Storage | S01–S06 | 6 | ephemeral/static/dynamic volumes, PVC binding/expansion, StorageClass/CSI, access/reclaim semantics |
| Troubleshooting | T01–T12 | 12 | applications, probes, scheduling, Services, DNS, logs/events, usage, nodes, runtime/kubelet, control plane/etcd, ephemeral debug |

The metadata has 58 rows including its header: 57 tasks total. Use `make check-metadata` to prove prompt, metadata and validator IDs agree.

## Talos versus kubeadm caveat

Talos Linux is API-managed, immutable, and does not provide the host-shell/systemd/package workflow used in kubeadm exam exercises. Do **not** run `kubeadm init`, `join`, `upgrade`, apt/yum package steps, edit static pod files, SSH to nodes, or manipulate `/etc/kubernetes` on this homelab. Talos etcd backup, certificate, component-log, and upgrade operations use `talosctl` and Talos machine configuration; they are represented here as read-only inspection or written simulation. Actual etcd restore, Talos upgrade, quorum recovery, node reset, static local-volume binding, kubeadm installation/join, and kubeadm upgrade require a disposable, snapshot-backed lab with an accepted outage—not this cluster.

## Static validation

`make test` runs `bash -n`, metadata/task/scorer consistency checks, YAML client dry-runs when `kubectl` is present, and verifies scripts contain no direct mutation during tests. It does not contact or mutate a cluster. See `tests/static.sh`.
