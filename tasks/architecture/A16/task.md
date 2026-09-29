# A16 — Model an operator install offline

| Field | Value |
|---|---|
| Task ID | `A16` |
| CKA pillar | `architecture` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 2 |

## Scenario and objective

A synthetic Signal API is in `tasks/architecture/A16/resources/crd.yaml`; no CRD is installed. Create `.lab/A16/<namespace>/evidence/A16-operator.yaml` with a compatible CRD, namespaced `Signal` custom resource `harbor-signal`, controller Deployment `signal-operator`, ServiceAccount `signal-operator`, a namespaced Role restricted to get/list/watch Signals, and RoleBinding linking that ServiceAccount. Use one replica of `busybox:1.36` as a simulated controller (not a functional installation). Namespace resources must use the active lab namespace, every document the owner label, and the cluster-scoped CRD also the active `cka-lab.io/prefix` label. Model only: do not apply or install any operator.

## Scope and constraints

Local artifacts only; never apply cluster-scoped definitions or rendered components. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A16` (including Pod templates). Never commit `.lab/` or credentials.
