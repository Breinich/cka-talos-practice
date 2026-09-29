# W08 — Apply node affinity and pod anti-affinity

| Field | Value |
|---|---|
| Task ID | `W08` |
| CKA pillar | `workloads` |
| Mode | `live` |
| Capability | `core` |
| Points | 2 |

## Scenario

The owned two-replica `ember-placement` Deployment currently has no scheduling rules. It should spread onto two distinct Ready, untainted workers. Namespace: `${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w08}`; use `kubectl -n "$NAMESPACE"` after setting `NAMESPACE="${CKA_LAB_NAMESPACE:-${CKA_LAB_PREFIX:-cka-practice}-w08}"`.

## Task

Discover worker labels and topology. Set required node affinity for existence of `node-role.kubernetes.io/worker`; set **required** Pod anti-affinity against `app=ember-placement` on `kubernetes.io/hostname`. Keep two replicas and do not label/taint nodes.

## Expected state

Both required rules appear on the template (preferred rules do not count); two running ready replicas occupy distinct eligible worker nodes. With fewer than two eligible workers, validation SKIPs.

## Safety boundary

Work only in the configured lab namespace; label new live objects `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=W08` (including Pod templates). Do not modify nodes, controllers, cluster-scoped objects, PVCs or PVs.

## Validation

```bash
./tasks/workloads/W08/score.sh
./tasks/workloads/W08/score.sh --json
```

Two independent end-state criteria are scored. The validator does not repair resources or publish a solution.

From any directory, run `./tasks/workloads/W08/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
