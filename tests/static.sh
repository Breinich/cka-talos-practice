#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

for f in scripts/*.sh lib/*.sh tests/*.sh; do bash -n "$f"; done
printf 'ok: bash syntax\n'

header="$(head -1 metadata/tasks.tsv)"
[[ "$header" == $'id\tdomain\tpoints\tmode\trequires\ttitle' ]] || fail "metadata header"
awk -F '\t' 'NR>1 {if (NF!=6 || $1!~/^[AWNST][0-9][0-9]$/ || $3!~/^[1-9][0-9]*$/) exit 1; if(seen[$1]++) exit 2; if($2!~/^(architecture|workloads|networking|storage|troubleshooting)$/) exit 3; if($4!~/^(live|conditional|read-only|simulation|disposable-kubeadm)$/) exit 4}' metadata/tasks.tsv || fail "invalid metadata row"

missing=0
while IFS=$'\t' read -r id domain points mode requires title; do
  [[ "$id" == id ]] && continue
  task_file="tasks/$domain/$id.md"
  [[ -f "$task_file" ]] || { echo "missing task file: $task_file" >&2; missing=1; continue; }
  grep -Fq "# $id — $title" "$task_file" || { echo "task title mismatch: $id" >&2; missing=1; }
  grep -Fq "| Task ID | \`$id\` |" "$task_file" || { echo "task ID metadata missing: $id" >&2; missing=1; }
  grep -Fq "| CKA pillar | \`$domain\` |" "$task_file" || { echo "task pillar mismatch: $id" >&2; missing=1; }
  grep -Fq "| Mode | \`$mode\` |" "$task_file" || { echo "task mode mismatch: $id" >&2; missing=1; }
  grep -Fq "| Capability | \`$requires\` |" "$task_file" || { echo "task capability mismatch: $id" >&2; missing=1; }
  grep -Fq "| Points | $points |" "$task_file" || { echo "task points mismatch: $id" >&2; missing=1; }
  grep -Fq "./scripts/validate.sh --task $id" "$task_file" || { echo "task validation command missing: $id" >&2; missing=1; }
  grep -Fq "($task_file)" TASKS.md || { echo "task index link missing: $id" >&2; missing=1; }
  if ! grep -Eq "^[[:space:]]+$id\)" scripts/validate.sh && [[ "$mode" != disposable-kubeadm ]]; then
    echo "missing validator: $id" >&2; missing=1
  fi
done < metadata/tasks.tsv
[[ $missing -eq 0 ]] || fail "ID consistency"
# Every explicit validator and task file must have matching metadata.
while read -r id; do awk -F '\t' -v id="$id" 'NR>1 && $1==id {ok=1} END{exit !ok}' metadata/tasks.tsv || fail "orphan validator $id"; done < <(sed -nE 's/^[[:space:]]+([AWNST][0-9]{2})\).*/\1/p' scripts/validate.sh)
while read -r task_file; do
  id="$(basename "$task_file" .md)"; domain="$(basename "$(dirname "$task_file")")"
  awk -F '\t' -v id="$id" -v domain="$domain" 'NR>1 && $1==id && $2==domain {ok=1} END{exit !ok}' metadata/tasks.tsv || fail "orphan or misplaced task file $task_file"
done < <(find tasks -type f -name '*.md' | sort)
[[ "$(find tasks -type f -name '*.md' | wc -l)" -eq "$(($(wc -l < metadata/tasks.tsv)-1))" ]] || fail "task file count mismatch"
printf 'ok: %s task files, IDs, index links, and validator metadata agree\n' "$(($(wc -l < metadata/tasks.tsv)-1))"

for f in fixtures/base/*.yaml fixtures/troubleshooting/*.yaml; do
  grep -q 'cka-lab.io/owner: cka-talos-practice' "$f" || fail "fixture lacks owner label: $f"
done
printf 'ok: fixture ownership metadata\n'

# A client dry-run is useful when kubectl can parse without discovery. Skip cleanly otherwise.
if command -v kubectl >/dev/null 2>&1; then
  tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
  sed 's/__NAMESPACE__/cka-practice/g; s/__PREFIX__/cka-practice/g' fixtures/base/lab.yaml fixtures/troubleshooting/broken.yaml >"$tmp"
  if kubectl apply --dry-run=client --validate=false --request-timeout=2s -f "$tmp" >/dev/null 2>&1; then
    printf 'ok: kubectl client dry-run\n'
  else
    printf 'skip: kubectl client dry-run requires API discovery in this environment\n'
  fi
fi

grep -q 'kubectl apply' scripts/setup.sh || fail "setup has no fixture apply"
grep -q 'ns_owned' scripts/teardown.sh || fail "teardown lacks ownership gate"
grep -q 'cka-lab.io/prefix=\$PREFIX' scripts/teardown.sh || fail "cluster cleanup lacks prefix selector"
CKA_LAB_PREFIX=cka-practice CKA_LAB_NAMESPACE=cka-practice bash -c 'source lib/common.sh; validate_scope'
if CKA_LAB_PREFIX=bad_prefix CKA_LAB_NAMESPACE=bad_prefix bash -c 'source lib/common.sh; validate_scope' >/dev/null 2>&1; then fail "unsafe scope accepted"; fi
printf 'ok: safety invariants\nall static tests passed\n'
