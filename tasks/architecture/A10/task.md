# A10 — Triage Talos services without repair

| Field | Value |
|---|---|
| Task ID | `A10` |
| CKA pillar | `architecture` |
| Mode | `read-only` |
| Capability | `talosctl` |
| Points | 2 |

## Scenario and objective

If `talosctl` is available and configured, use read-only `talosctl health` and `talosctl services` for an existing control-plane machine. In `.lab/A10/<namespace>/evidence/A10.json` record `node`, `health` (healthy/unhealthy), `kubelet` and `containerd` (running/stopped), and `observation` (a literal status line from `talosctl services -n <node>`). Never save talosconfig or issue service restarts, reset, apply-config or upgrades.

The active namespace is `CKA_LAB_NAMESPACE` (default `cka-practice-a10`); the active prefix is `CKA_LAB_PREFIX` (default `cka-practice`). If setup used flags, export matching `CKA_LAB_PREFIX` and `CKA_LAB_NAMESPACE` before validation; evidence is isolated under `.lab/A10/<namespace>/evidence/` (no cluster state file or namespace is created).

## Safety boundary

Observation only; do not change cluster resources, certificates, host configuration or services. All created cluster objects require `cka-lab.io/owner=cka-talos-practice` and `cka-lab.io/task=A10` (including Pod templates). Never commit `.lab/` or credentials.

## Validation

```bash
./tasks/architecture/A10/score.sh
./tasks/architecture/A10/score.sh --json
```

Two independent outcomes are scored where applicable; offline/disposable limits are called out above. Evidence observations should be reviewed against their sources when a remote endpoint is not available to the scorer.

From any directory, run `./tasks/architecture/A10/setup.sh` (relative to repository root), then use its `score.sh` and `teardown.sh`. Export `CKA_LAB_NAMESPACE` if using a custom namespace. Each task has an independent state/evidence directory; `--yes` confirms context only.
