# A17 — Assess one failure before expanding HA

| Field | Value |
|---|---|
| Task ID | `A17` |
| CKA pillar | `architecture` |
| Mode | `simulation` |
| Capability | `core` |
| Points | 3 |

## Scenario and objective

`tasks/architecture/A17/resources/ha.json` describes three control-plane/etcd members in separate zones; `elm` is unhealthy, and a candidate replacement would be placed in the same zone. Save `.lab/A17/<namespace>/evidence/A17.json` with `members`, `healthyMembers`, `quorum`, `survivesAnotherFailure` (boolean), `apiEndpoint`, `endpointInSANs` (boolean), `replacementZone`, `membershipMutationAllowedNow` (boolean), and `nextStep` (choose `restore-elm-health`, `add-fourth-member`, or `replace-api-endpoint`). Use the input to decide whether another failure can be tolerated. Do not patch Talos machine config or change etcd membership.

## Scope and constraints

Local artifacts only; never apply cluster-scoped definitions or rendered components. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A17` (including Pod templates). Never commit `.lab/` or credentials.
