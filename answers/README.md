# Answer notes

This directory is intentionally separate from `TASKS.md` and is never read or quoted by the scorer. Use it only after attempting a task.

## Architecture

- **A01/A06/A09/A14:** Prefer `kubectl version`, `api-resources`, `api-versions`, `get crd -o yaml`, targeted `-n kube-system get pods`, and TLS/certificate inspection that emits no private material.
- **A02:** `kubectl create token exam-sa --duration=15m` can supply a short-lived credential. Construct a new kubeconfig with `config set-cluster`, `set-credentials`, and `set-context`; never flatten the admin config into the evidence file.
- **A03–A05:** `create role`, `create rolebinding`, and `auth can-i --as=system:serviceaccount:<ns>:exam-sa` are the fastest safe path. Grant only pod read verbs.
- **A07:** `helm template <release> <chart> --namespace <ns> -f <values>` is rendering, not installation.
- **A08:** Compare `a08-kustomization.yaml`; adjust its relative base path if copying it elsewhere. Preview with `kubectl kustomize` before apply.
- **A10/A11:** Talos uses machine configuration and Talos APIs, not SSH/systemd. A restore runbook must preserve an encrypted snapshot, confirm quorum/endpoint, state maintenance/recovery prerequisites, and include health verification.
- **A12/A13:** Use only disposable kubeadm VMs. Follow the version-specific Kubernetes package repository and `kubeadm upgrade plan`; control plane first, then drain/upgrade/uncordon each worker.

## Workloads

Use `kubectl create ... --dry-run=client -o yaml` as a starting point, then edit declaratively. Inspect `rollout history/status/undo`. A Job needs a terminating command; suspend the CronJob to avoid background churn. DaemonSets should tolerate only existing worker taints that are actually needed. StatefulSets need a matching headless `serviceName`. Use preferred anti-affinity to remain schedulable. Never add a node taint merely to satisfy W09.

## Networking

A Service selector must match pod labels; its `targetPort` must match a listening container port/name. EndpointSlices are the authoritative endpoint check. Headless Services use `clusterIP: None`. Start NetworkPolicy with podSelector/policyTypes, then make explicit DNS and application allowances and test from labeled Pods. Ingress and HTTPRoute need controllers/listeners, not merely API objects; use the detected class/Gateway.

## Storage

`emptyDir` is Pod-lifetime storage. For the static simulation, use a uniquely named, tiny lab-owned PV, matching `storageClassName`/`volumeName`, and a consuming Pod; client-dry-run it only. Use a real backend only in a disposable lab where its storage is known safe. A dynamic claim may wait for first consumer. Check `allowVolumeExpansion` before increasing a request; claims cannot shrink. Reclaim policy controls the PV after claim deletion, not application-level backup.

## Troubleshooting

Work from symptoms to events, object spec/status, logs, endpoints/DNS, then nodes/control plane. Fix the smallest bad field. T01 needs a real image tag; T02's server listens on port 80; T03 should lose only the impossible selector; T04's selector should match `app=web`. Use `logs --previous` only after a restart. On Talos, use `talosctl health`, `service`, `logs`, and read-only etcd member/status commands—never SSH or `systemctl`.
