# Contributing

Keep all live exercises namespace-scoped unless a cluster-scoped concept cannot be practiced otherwise. Cluster-scoped exercise objects must use the ownership label and be handled by teardown. Add each task ID to `metadata/tasks.tsv`, `TASKS.md`, and the scorer; keep solutions under `answers/`. Run `make test` before committing. Never capture credentials, live Secret values, or homelab-specific addresses.
