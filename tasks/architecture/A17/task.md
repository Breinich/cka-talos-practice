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

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a17`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A17/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Local artifacts only; never apply cluster-scoped definitions or rendered components. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A17` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A17/score.sh
./tasks/architecture/A17/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A17/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
