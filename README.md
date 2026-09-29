# Safe CKA practice for Talos Kubernetes

A namespace-scoped, self-scoring practice bank for the five current CKA domains, designed for the existing Kubernetes v1.35 Talos cluster whose expected context is `admin@lake`. It contains 60 tasks and deliberately does **not** make changes when cloned or tested.

> This repository is not an installer and no script is automatically run. Review every command. Never point practice tooling at a production context.

## Prerequisites

Required for setup/scoring: Bash 4+, `kubectl`, Python 3, `sed`, `grep`, `awk`, and a reachable Kubernetes API. `make test` and architecture offline scoring additionally need PyYAML for manifest parsing. Your identity needs permissions for namespaced exercise resources, read-only discovery of namespaced APIs and PVs, and read access to lab-owned storage; cluster-scoped PV/RBAC installation is simulation-only. Optional: configured `talosctl` for read-only Talos tasks and `helm` for local rendering. A14 uses Python TLS with the current cluster CA, not private keys. Metrics Server, a NetworkPolicy-enforcing CNI, an Ingress controller, Gateway API, and dynamic storage are detected, not assumed. Helm and Gateway API are known to be absent initially, and no default StorageClass is assumed.

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
- Capability checks are conservative. NetworkPolicy is enabled only when the API plus a recognized enforcing CNI are visible. Storage tasks S03/S05 require an explicitly approved disposable class (below); a default class alone is not approval. Conditional tasks become `SKIP`, not failures, when absent.
- Read-only Talos tasks prohibit apply-config, reset, reboot, service restarts and quorum changes. Kubeadm lifecycle tasks are explicitly unsupported here.
- Teardown refuses pre-existing namespaces, owned PVCs/PVs, unowned namespaced objects, or incomplete API discovery. It deletes no cluster-scoped objects. Never add the ownership label to unrelated resources.
- `.lab/state.env` and mode-0600 `before.yaml` record the original lab-owned resources (not unrelated namespace contents). No credentials should be placed in evidence except the intentionally short-lived A02 kubeconfig.

## Usage

```bash
./scripts/setup.sh                 # safe on the expected context
# On another intentionally selected disposable context only:
./scripts/setup.sh --yes

less TASKS.md                         # pillar-grouped task index
less tasks/workloads/W01.md           # one complete task prompt
./scripts/validate.sh --task W01
./scripts/validate.sh --task W01 --json
./scripts/validate.sh              # all tasks, human summary
./scripts/validate.sh --json       # all tasks, machine summary
```

Override scope with `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` or setup flags. The namespace must equal or begin with the prefix. Keep evidence under `.lab/evidence/`; it is gitignored. Validators are read-only, deterministic, and print only criterion counts—not answers. Solution notes live separately in `answers/`.

`make setup`, `make score`, `make teardown`, and `make restore` are convenience equivalents. Setup is idempotent: rerunning it restores only seeded fixtures and retains the original pre-setup backup.

Storage S02/S06 are **offline hostPath simulations**, not Talos instructions. Setup seeds only the broken, ephemeral S01 Deployment; it never creates a PV/PVC. For S03/S05, first verify a disposable dynamic CSI backend, acceptable `Delete` reclaim semantics, quota, data-handling/backup and a manual cleanup plan. Only then opt in with `CKA_LAB_STORAGE_CLASS=<reviewed-class> CKA_LAB_STORAGE_APPROVED=true ./scripts/setup.sh`. The class must exist, use a real provisioner (not `no-provisioner`), and advertise `Delete` reclamation; S05 also requires expansion. These checks cannot prove that a backend is safe: the operator owns that decision. Run setup without both opt-ins to disable the capability again. Scoring reads the recorded class in `.lab/capabilities.env`; never hand-edit that file. Do not create S03 storage on a non-disposable backend. After data review, manually delete owned Pod/PVC and inspect any remaining PV before reset/restore/teardown; no script deletes persistent data automatically.

### Task organization

`TASKS.md` is the pillar-grouped index. Individual prompts live at `tasks/<pillar>/<ID>.md`; every file repeats the authoritative task ID, mode, capability, points, safety boundary, and one-task human/JSON validation commands. The five directories are `architecture`, `workloads`, `networking`, `storage`, and `troubleshooting`. Machine-readable weights and modes remain centralized in `metadata/tasks.tsv`, while solutions remain outside the task tree under `answers/`.

## Scoring

Task weights are in `metadata/tasks.tsv` (128 total configured points before capability exclusions). Each task has two independently checked criteria; partial criteria receive floor-rounded points (a one-point task can be `PARTIAL` at 0/1). `PASS`, `PARTIAL`, and `FAIL` apply only to supported tasks. `SKIP` means a detected optional API/controller/capability is unavailable. `UNSUPPORTED` means the exercise belongs in a disposable kubeadm environment or a required local tool is missing. Skipped/unsupported points are excluded from the denominator. A nonzero scorer exit means not all applicable points were earned; JSON remains available for automation.

Storage scoring checks the exact offline PV/PVC/Pod binding and retention fields, the seeded emptyDir sharing and observed receipt, live claim capacity/mounts for approved conditional work, and a fresh read-only StorageClass/CSIDriver inventory. An S05 end-state cannot independently prove historical size; perform S03 first and observe the expansion. The architecture scorer verifies live RBAC, identity, and render structure, and compares synthetic incident answers to bundled input cases; a few Talos observations still require human review. Networking repairs N01/N03/N08 use owned, initially miswired Services and ready EndpointSlice checks; N04–N07/N09/N11 are offline simulations that do not require NetworkPolicy enforcement, installed Ingress/Gateway controllers or CRDs, or changes to CoreDNS. N10 checks the saved HTTP result against a live repaired endpoint, but its local port-forward transcript still requires human review. The scorer checks end state or sanitized evidence; it never repairs resources and does not emit full commands or solutions. Some evidence checks establish that the requested diagnostic concepts were recorded, not that every conclusion is semantically correct—review those manually against `answers/`.

## Reset, teardown, and restore

```bash
./scripts/reset.sh --yes       # delete owned lab scope, wait, and seed it again
./scripts/teardown.sh          # remove lab-owned namespace and labelled cluster objects
./scripts/restore.sh           # return to the state captured before first setup
```

Normally the namespace did not exist, so restore is equivalent to safe teardown. For a namespace that already existed, restore deletes only current lab-owned task-managed kinds (including HTTPRoutes when available) and reapplies only the lab-owned baseline; unrelated resources are left untouched. Setup refuses fixture-name collisions with unrelated objects. Persistent storage is never deleted automatically: restore, reset and teardown refuse any owned PVC/PV and print names for separate manual review/removal. YAML backups do **not** contain volume data; Services can receive new IPs after restore and runtime/controller-generated fields may not round-trip. Teardown/reset also refuse a namespace containing unowned resources; system-generated unowned objects can require manual review. The backup remains for audit. Namespace deletion is asynchronous. Review `.lab/state.env` and `.lab/before.yaml` before recovery if setup was interrupted. Never manually edit `state.env`.

## Task map

| Current CKA domain | IDs | Tasks | Coverage |
|---|---:|---:|---|
| Cluster Architecture, Installation & Configuration | A01–A18 | 18 | API discovery, kubeconfig, RBAC, ServiceAccounts, CRD inspection/offline operator model, Helm/Kustomize offline component renders, admission, HA control-plane design, Talos, etcd, certificates, kubeadm install/join/upgrade |
| Workloads & Scheduling | W01–W13 | 13 | resources, rollout/rollback, Jobs/CronJobs, DaemonSets, StatefulSets, configuration, affinity, taints, HPA, probes/security, init/sidecars, disruption budgets |
| Services & Networking | N01–N11 | 11 | seeded Service/EndpointSlice faults, offline DNS/CoreDNS and egress policy cases, Ingress-to-HTTPRoute conversion, safe Service-type simulation, port-forward |
| Storage | S01–S06 | 6 | ephemeral/static/dynamic volumes, PVC binding/expansion, StorageClass/CSI, access/reclaim semantics |
| Troubleshooting | T01–T12 | 12 | applications, probes, scheduling, Services, DNS, logs/events, usage, nodes, runtime/kubelet, control plane/etcd, ephemeral debug |

The metadata has 61 rows including its header: 60 tasks total. Use `make check-metadata` to prove prompt, metadata and validator IDs agree.

## Talos versus kubeadm caveat

Talos Linux is API-managed, immutable, and does not provide the host-shell/systemd/package workflow used in kubeadm exam exercises. Do **not** run `kubeadm init`, `join`, `upgrade`, apt/yum package steps, edit static pod files, SSH to nodes, or manipulate `/etc/kubernetes` on this homelab. Talos etcd backup, certificate, component-log, and upgrade operations use `talosctl` and Talos machine configuration; they are represented here as read-only inspection or written simulation. Actual etcd restore, Talos upgrade, quorum recovery, node reset, static local-volume binding, kubeadm installation/join, and kubeadm upgrade require a disposable, snapshot-backed lab with an accepted outage—not this cluster.

## Static validation

`make test` runs `bash -n`, metadata/task/scorer consistency checks, offline PyYAML parsing and per-document fixture ownership checks, plus mocked negative/positive scorer and restore safety tests. It neither contacts nor mutates a cluster. See `tests/static.sh`.
