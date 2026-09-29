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
  if ! grep -Eq "^[[:space:]]+$id\)|\|$id\)|\|$id\||^[[:space:]]+$id\|" scripts/validate.sh && [[ "$mode" != disposable-kubeadm ]]; then
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
total_points="$(awk -F '\t' 'NR>1 {sum+=$3} END {print sum}' metadata/tasks.tsv)"
grep -Fq "($total_points total configured points" README.md || fail "README score total mismatch"
printf 'ok: %s task files, IDs, index links, score total, and validator metadata agree\n' "$(($(wc -l < metadata/tasks.tsv)-1))"

# Parse every YAML document offline. A matching label in another document is not enough.
python3 - <<'PYTEST'
import glob
import sys
try:
    import yaml
except ImportError:
    sys.exit("PyYAML required for offline fixture validation (python3 -m pip install PyYAML)")
for filename in glob.glob("fixtures/*/*.yaml"):
    with open(filename, encoding="utf-8") as stream:
        docs = list(yaml.safe_load_all(stream))
    if not docs:
        sys.exit(f"empty fixture: {filename}")
    for index, doc in enumerate(docs, 1):
        if not isinstance(doc, dict) or not doc.get("apiVersion") or not doc.get("kind") or not doc.get("metadata", {}).get("name"):
            sys.exit(f"invalid document {index}: {filename}")
        if doc["metadata"].get("labels", {}).get("cka-lab.io/owner") != "cka-talos-practice":
            sys.exit(f"unowned document {index}: {filename}")
        if doc["metadata"].get("namespace") != "__NAMESPACE__":
            sys.exit(f"out-of-scope document {index}: {filename}")
print("ok: offline YAML parsing, every fixture document owned and scoped")
PYTEST
python3 - <<'PYTEST'
import yaml
items=list(yaml.safe_load_all(open('fixtures/base/networking.yaml')))
assert len(items)==4
api,front,catalog,port=items
assert api['spec']['template']['spec']['containers'][0]['ports']==[{'name':'http','containerPort':80}]
assert front['spec']['selector']!=api['spec']['selector']['matchLabels']
assert catalog['spec']['selector']!=api['spec']['selector']['matchLabels']
assert port['spec']['selector']==api['spec']['template']['metadata']['labels']
assert port['spec']['ports'][0]['targetPort']==81
assert all(i['metadata']['namespace']=='__NAMESPACE__' for i in items)
print('ok: networking starting faults are seeded and scoped')
PYTEST
python3 - <<'PYTEST'
import yaml
s=list(yaml.safe_load_all(open('fixtures/troubleshooting/broken.yaml')))
by_name={d['metadata']['name']: d for d in s}
assert len(s)==6 and all(d['metadata']['namespace']=='__NAMESPACE__' for d in s)
assert by_name['dns-stray']['spec']['dnsPolicy']=='None'
assert by_name['dns-stray']['spec']['dnsConfig']['nameservers']==['192.0.2.53']
assert by_name['log-churn']['spec']['template']['spec']['containers'][0]['command'][-1].endswith('exit 17')
assert by_name['sable-worker']['spec']['nodeSelector']
assert all(d['metadata']['labels']['cka-lab.io/owner']=='cka-talos-practice' for d in s)
assert len(list(yaml.safe_load_all(open('samples/troubleshooting/qos.yaml'))))==3
print('ok: troubleshooting seeded faults and offline eviction case')
PYTEST
python3 - <<'PYTEST'
import pathlib, yaml
base=pathlib.Path('samples/architecture')
for filename in ('crd.yaml','component.yaml','chart/Chart.yaml','chart/values.yaml'):
    assert list(yaml.safe_load_all((base/filename).read_text())),filename
assert (base/'chart/templates/deployment.yaml').is_file()
print('ok: synthetic architecture inputs parse offline')
PYTEST

python3 - <<'PYTEST'
import yaml
s=list(yaml.safe_load_all(open('fixtures/base/storage.yaml')))
assert len(s)==1 and s[0]['metadata']['name']=='lighthouse-workspace'
c=s[0]['spec']['template']['spec']['containers']
assert c[0]['volumeMounts']==[{'name':'workspace','mountPath':'/workspace'}]
assert 'volumeMounts' not in c[1]
for name in ('static-broken','reclaim-broken'):
    d=list(yaml.safe_load_all(open(f'samples/storage/{name}.yaml')))
    assert d[0]['spec']['storageClassName']==''
    assert d[0]['metadata']['labels']['cka-lab.io/prefix']=='__PREFIX__'
    assert d[1]['metadata']['namespace']=='__NAMESPACE__'
assert list(yaml.safe_load_all(open('samples/storage/static-broken.yaml')))[1]['spec']['accessModes']!=['ReadWriteOnce']
assert list(yaml.safe_load_all(open('samples/storage/reclaim-broken.yaml')))[0]['spec']['persistentVolumeReclaimPolicy']=='Delete'
print('ok: seeded storage fault and offline broken binding/policy inputs')
PYTEST
./tests/behavior.sh
python3 ./tests/storage.py
python3 ./tests/workloads.py
python3 ./tests/networking.py
python3 ./tests/troubleshooting.py

grep -q 'kubectl apply' scripts/setup.sh || fail "setup has no fixture apply"
grep -q 'ns_owned' scripts/teardown.sh || fail "teardown lacks ownership gate"
grep -q 'refuse_storage_cleanup' scripts/teardown.sh || fail "storage guard missing"
CKA_LAB_PREFIX=cka-practice CKA_LAB_NAMESPACE=cka-practice bash -c 'source lib/common.sh; validate_scope'
if CKA_LAB_PREFIX=bad_prefix CKA_LAB_NAMESPACE=bad_prefix bash -c 'source lib/common.sh; validate_scope' >/dev/null 2>&1; then fail "unsafe scope accepted"; fi
printf 'ok: safety invariants\nall static tests passed\n'
