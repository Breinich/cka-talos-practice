# W11 tutorial — Use probes and security context

> **Spoilers:** this is the worked guide. Attempt [`task.md`](task.md) first if desired; prompts contain no solutions.

## Objective and concepts

The scenario, constraints, exact object names and end-state criteria are task-specific. The worked walkthrough below expands the answer-free prompt into the concrete fields and operations to use.

## Task-specific walkthrough

## Scenario

An isolated HTTP responder `ember-guard` is absent. It must expose port 8080 without privilege escalation. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w11}`; use `kubectl -n "$NAMESPACE"` after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w11}"`.

## Task

Create an owned Pod using `busybox:1.36` with command `httpd -f -p 8080`, TCP readiness and liveness probes on 8080, container `runAsUser: 10001`, and `allowPrivilegeEscalation: false`. Keep it running; avoid a privileged port.

## Expected state

The correct probes and security fields are on the container; the HTTP process is ready in a Running Pod.

## Step-by-step approach

1. **Establish the boundary.** Check the mode and work only in this task's namespace or local evidence path. Verify your configured namespace and context before any live API query. This task's own input files are in `resources/` when applicable.
2. **Inspect state and source inputs first.** Query the named object and its dependencies; for a controller, inspect its template, status and events before editing. For local simulations, read the supplied file and preserve all non-target fields. Prefer narrow inspection such as `kubectl -n "$NS" get <kind> <name> -o yaml`, `kubectl -n "$NS" describe <kind> <name>`, and `kubectl -n "$NS" get events --sort-by=.lastTimestamp`. Replace placeholders only with active scope values.
3. **Apply the smallest correction or create the requested artifact.** Preserve object identity, selectors, ports, labels, image, replicas and existing safe properties unless the prompt explicitly requires a change. Use declarative edits or an evidence manifest when appropriate. Do not use the task itself as a reason to mutate cluster-scoped resources, nodes or unrelated workloads.
4. **Wait for the system to converge.** After permitted changes, wait for the specific rollout, Ready condition, binding, endpoint, capacity, or status needed. Inspect the resulting state independently; a successful request alone is not proof. For read-only tasks, record observations as seen. For simulations, reason only from provided inputs and never apply them.
5. **Write required evidence exactly.** Create the named file and keys/fields exactly as specified in the prompt. Pull live values from fresh inspection. Avoid credentials, Secret data, private keys, kubeconfigs, and irrelevant system output.
6. **Check the task result.** Run the task-local score wrapper after the solution is in place. A failed criterion identifies a mismatch to investigate; do not alter scorer or fixtures.

## Command patterns

Set `NS` to the configured task namespace. Useful read-only patterns include `kubectl -n "$NS" get pods -o wide`, `kubectl -n "$NS" get <kind> <name> -o yaml`, and `kubectl -n "$NS" describe pod <pod>`. For Deployment convergence, use `kubectl -n "$NS" rollout status deployment/<name>` and inspect replica counts afterwards. For Services, inspect EndpointSlices as well as selectors and ports. For offline YAML, client dry-run is a syntax/render check only and must not be followed by an apply. Use `helm template` or `kubectl kustomize` only where the task specifically asks for a local render. Talos queries are read-only; do not restart services or change machine configuration.

## Verification and pitfalls

Compare exact fields and values, not general intent: resource names, selector labels, API versions, container names, port names, evidence keys, path, namespace and quantities matter. Controller-owned children can lag behind the parent update. Preserve immutable Pod fields by replacing only the owned Pod when the prompt requires it. A scheduled Pod or an EndpointSlice address alone does not prove all task conditions. Read the task-specific scoring criteria after every change.

## Safety and cleanup

Offline simulations, hostPath/PV samples, NodePort examples, hypothetical ingress/Gateway resources, synthetic operator manifests and component renderings remain local; never apply them. Never perform kubeadm or Talos destructive operations on a homelab, induce pressure, drain nodes, or expose live workloads. Conditional capability unavailable means stop and accept SKIP/UNSUPPORTED; do not install infrastructure. Clean only the task's own verified disposable namespace with its lifecycle wrapper. Storage teardown can intentionally refuse claims/volumes; assess data and reclaim policy manually rather than force deletion.

**Source inputs:** `workloads/W11/resources/` when present. See [`task.md`](task.md) for the answer-free prompt.
