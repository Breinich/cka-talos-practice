# A08 Tutorial: Promote a local overlay into the lab

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Kustomize overlays keep upstream base reusable.** Setup creates a working copy of base; make changes only to its overlay, not source base. The overlay must supply prefix-derived name, namespace, replica count and labels on both resource and Pod template.

Inspect `$LAB/A08-kustomize/overlay/kustomization.yaml` plus the copied base. Configure the overlay with the local base reference, namespace `$NS`, `namePrefix: <active-prefix>-`, `replicas` entry for the base Deployment set to 2, and `commonLabels`/patch so `cka-lab.io/owner=cka-talos-practice` appears on Deployment and Pod template. Render first: `kubectl kustomize "$LAB/A08-kustomize/overlay"`; apply only the rendered Deployment to `$NS` (or use `kubectl apply -k` on the overlay), then `kubectl -n "$NS" rollout status deployment/<prefix>-kustom-app`. Check names/labels and ready replicas; do not change base.

## Task-scoped workflow: authorized live namespace

The user authorizes the exact task-directed change only on this task's owned, isolated resources in its configured unique namespace. Set `NS` to that namespace, inspect the named starting state, and apply/edit only the object and fields described in this tutorial. Newly created objects require the task ownership labels from the prompt. Verify through namespaced reads and this task's scorer. Do not touch unrelated namespaces/workloads or cluster-scoped RBAC, CRDs, webhooks, StorageClasses/PVs, nodes, `kube-system`, Talos machine configuration, etcd, or control-plane services. Clean up only this task's verified namespace through its lifecycle; heed storage cleanup refusal.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
