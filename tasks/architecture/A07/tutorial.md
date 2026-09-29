# A07 Tutorial: Render a local release without installing it

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Helm template renders are local output, not releases.** `helm template` evaluates chart templates without creating a release or contacting the API server.

Inspect `tasks/architecture/A07/resources/chart/Chart.yaml` and values to learn the image and template naming. Chart `values.yaml` uses key `replicas`, so render with `helm template harbor-relay tasks/architecture/A07/resources/chart -n "$NS" --set replicas=2 > "$LAB/evidence/A07-rendered.yaml"`. Inspect the result with `grep`/`yq` or `kubectl create --dry-run=client -f ... -o yaml`; verify Deployment name `harbor-relay-relay`, active namespace, two replicas, selector/template label `app=harbor-relay-relay`, and image `nginx:1.27-alpine`. Do not use `helm install` or apply the render.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
