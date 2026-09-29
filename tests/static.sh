#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

for f in scripts/*.sh lib/*.sh tests/*.sh tasks/*/*/*.sh; do bash -n "$f"; done
printf 'ok: bash syntax\n'

header="$(head -1 metadata/tasks.tsv)"
[[ "$header" == $'id\tdomain\tpoints\tmode\trequires\ttitle' ]] || fail "metadata header"
awk -F '\t' 'NR>1 {if (NF!=6 || $1!~/^[AWNST][0-9][0-9]$/ || $3!~/^[1-9][0-9]*$/) exit 1; if(seen[$1]++) exit 2; if($2!~/^(architecture|workloads|networking|storage|troubleshooting)$/) exit 3; if($4!~/^(live|conditional|read-only|simulation|disposable-kubeadm)$/) exit 4}' metadata/tasks.tsv || fail "invalid metadata row"

missing=0
while IFS=$'\t' read -r id domain points mode requires title; do
  [[ "$id" == id ]] && continue
  task_file="tasks/$domain/$id/task.md"
  [[ -f "$task_file" ]] || { echo "missing task file: $task_file" >&2; missing=1; continue; }
  grep -Fq "# $id — $title" "$task_file" || { echo "task title mismatch: $id" >&2; missing=1; }
  grep -Fq "| Task ID | \`$id\` |" "$task_file" || { echo "task ID metadata missing: $id" >&2; missing=1; }
  grep -Fq "| CKA pillar | \`$domain\` |" "$task_file" || { echo "task pillar mismatch: $id" >&2; missing=1; }
  grep -Fq "| Mode | \`$mode\` |" "$task_file" || { echo "task mode mismatch: $id" >&2; missing=1; }
  grep -Fq "| Capability | \`$requires\` |" "$task_file" || { echo "task capability mismatch: $id" >&2; missing=1; }
  grep -Fq "| Points | $points |" "$task_file" || { echo "task points mismatch: $id" >&2; missing=1; }
  tutorial_file="tasks/$domain/$id/tutorial.md"
  [[ -f "$tutorial_file" ]] || { echo "missing tutorial: $tutorial_file" >&2; missing=1; }
  grep -Fq "tasks/$domain/$id/tutorial.md" SOLUTIONS.md || { echo "tutorial index link missing: $id" >&2; missing=1; }
  grep -Fq "($task_file)" TASKS.md || { echo "task index link missing: $id" >&2; missing=1; }
  if ! grep -Eq "^[[:space:]]+$id\)|\|$id\)|\|$id\||^[[:space:]]+$id\|" scripts/validate.sh && [[ "$mode" != disposable-kubeadm ]]; then
    echo "missing validator: $id" >&2; missing=1
  fi
done < metadata/tasks.tsv
[[ $missing -eq 0 ]] || fail "ID consistency"
# Every explicit validator and task file must have matching metadata.
while read -r id; do awk -F '\t' -v id="$id" 'NR>1 && $1==id {ok=1} END{exit !ok}' metadata/tasks.tsv || fail "orphan validator $id"; done < <(sed -nE 's/^[[:space:]]+([AWNST][0-9]{2})\).*/\1/p' scripts/validate.sh)
while read -r task_file; do
  id="$(basename "$(dirname "$task_file")")"; domain="$(basename "$(dirname "$(dirname "$task_file")")")"
  awk -F '\t' -v id="$id" -v domain="$domain" 'NR>1 && $1==id && $2==domain {ok=1} END{exit !ok}' metadata/tasks.tsv || fail "orphan or misplaced task file $task_file"
done < <(find tasks -type f -name 'task.md' | sort)
task_count="$(find tasks -type f -name task.md | wc -l)"
tutorial_count="$(find tasks -type f -name tutorial.md | wc -l)"
expected_count="$(($(wc -l < metadata/tasks.tsv)-1))"
[[ "$task_count" -eq "$expected_count" ]] || fail "task prompt count mismatch"
[[ "$tutorial_count" -eq "$expected_count" ]] || fail "tutorial count mismatch"
[[ "$(find tasks -type f -name '*.md' | wc -l)" -eq "$((expected_count * 2))" ]] || fail "task/tutorial markdown count mismatch"
python3 - <<'PYDOCS' || fail "task prompt contains solution material or lacks matching tutorial"
import csv, pathlib, re, sys
rows=list(csv.DictReader(open('metadata/tasks.tsv'), delimiter='\t'))
focused_sections=[]
for row in rows:
    base=pathlib.Path('tasks')/row['domain']/row['id']
    prompt=(base/'task.md').read_text()
    tutorial=base/'tutorial.md'
    if not tutorial.is_file(): sys.exit(f"missing tutorial: {base}")
    if re.search(r'^\s*```', prompt, re.M): sys.exit(f"fenced code in {base/'task.md'}")
    if prompt.count('`') % 2: sys.exit(f"unclosed inline code delimiter in {base/'task.md'}")
    if re.search(r'(?:tasks/.+/tutorial\.md|SOLUTIONS\.md|answers/)', prompt):
        sys.exit(f"solution link in answer-free prompt: {base/'task.md'}")
    if re.search(r'\b(?:kubectl|helm|talosctl|kubeadm|crictl|openssl|nslookup)\s+(?:get|describe|apply|create|delete|edit|patch|rollout|top|debug|template|upgrade|init|join|token|version|api-resources|auth|logs|exec|s-client|health|services|service)\b', prompt):
        sys.exit(f"solver command in {base/'task.md'}")
    if re.search(r'\b(?:sh\s+-c|sleep\s+7d|echo\s+[^\n`]+|test\s+-f)\b', prompt):
        sys.exit(f"shell solver snippet in {base/'task.md'}")
    content=tutorial.read_text()
    words=re.findall(r"[A-Za-z0-9][A-Za-z0-9._/-]*", content)
    if len(words) < 180:
        sys.exit(f"tutorial too short to be substantive: {tutorial} ({len(words)} words)")
    lowered=content.lower()
    if '## concept and task-specific procedure' not in lowered or ('## task-scoped workflow' not in lowered and '## external disposable-vm workflow' not in lowered):
        sys.exit(f"tutorial missing substantive sections: {tutorial}")
    focused=content.split('## Concept and task-specific procedure',1)[1]
    focused=focused.split('## Task-scoped workflow',1)[0] if '## Task-scoped workflow' in content else focused.split('## External disposable-VM workflow',1)[0]
    if len(re.findall(r"[A-Za-z0-9][A-Za-z0-9._/-]*", focused)) < 60:
        sys.exit(f"task-specific procedure too short: {tutorial}")
    technical_terms=re.findall(r'`([^`]{2,})`', focused)
    if len(set(technical_terms)) < 2:
        sys.exit(f"tutorial lacks task-specific technical identifiers: {tutorial}")
    focused_sections.append(re.sub(r'\s+', ' ', focused.strip()))
if len(set(focused_sections)) != len(rows):
    sys.exit("task-specific tutorial procedures are not all unique")
for row in rows:
    task=row['id']; mode=row['mode']
    content=(pathlib.Path('tasks')/row['domain']/task/'tutorial.md').read_text().lower()
    if task == 'A12' and any(line.rstrip().endswith(chr(92) * 2) for line in content.splitlines()):
        sys.exit('A12 kubeadm init continuation contains multiple trailing backslashes')
    if task in ('A12','A13'):
        if not all(term in content for term in ('ubuntu/debian', 'disposable', 'talos', 'proxmox-managed talos')):
            sys.exit(f"kubeadm guide lacks external-VM boundary: {task}")
        if content.count('```bash') < 2:
            sys.exit(f"kubeadm guide lacks actionable VM command sequences: {task}")
        required = (('kubeadm init', '--pod-network-cidr', 'kubeadm token create', 'worker-sandbox', 'flannel') if task == 'A12'
                    else ('kubeadm upgrade apply', 'apt-mark', 'kubectl drain', 'kubeadm upgrade node', 'kubectl uncordon', 'snapshot'))
        if not all(term in content for term in required):
            sys.exit(f"kubeadm guide missing essential lifecycle steps: {task}")
        kubeconfig_copy='sudo install -o "$(id -u)" -g "$(id -g)" -m 0600 /etc/kubernetes/admin.conf "$HOME/.kube/config"'.lower()
        if kubeconfig_copy not in content or 'export kubeconfig="$home/.kube/config"' not in content:
            sys.exit(f"kubeadm guide does not create operator-readable kubeconfig: {task}")
        if 'sensitive' not in content or 'repository' not in content or 'homelab' not in content:
            sys.exit(f"kubeadm guide does not protect kubeconfig credentials: {task}")
        if re.search(r'KUBECONFIG=/etc/kubernetes/admin.conf\s+kubectl|kubectl[^\n]*--kubeconfig(?:=|\s+)/etc/kubernetes/admin.conf', content):
            sys.exit(f"non-root kubectl points at root-only admin.conf: {task}")
        for line in content.splitlines():
            if '/etc/kubernetes/admin.conf' in line and 'sudo install -o' not in line:
                sys.exit(f"root-only admin.conf used outside ownership-adjusted copy: {task}")
    else:
        if 'authorized' not in content or 'unrelated' not in content or 'unique namespace' not in content:
            sys.exit(f"tutorial lacks scoped-authorization boundary: {task}")
    if mode == 'simulation' or task == 'A06':
        if not any(term in content for term in ('offline artifact', 'offline crd analysis')) or not any(term in content for term in ('do not use `kubectl apply`', 'do not apply', 'no live-resource mutation')):
            sys.exit(f"offline tutorial permits/misses live-apply boundary: {task}")
    elif mode == 'read-only':
        if 'read-only observations' not in content or 'do not create a namespace or change any kubernetes resource' not in content:
            sys.exit(f"read-only tutorial lacks no-mutation workflow: {task}")
    elif mode == 'conditional':
        if 'capability-gated' not in content or 'stop with skip' not in content or 'do not install optional shared infrastructure' not in content:
            sys.exit(f"conditional tutorial lacks capability skip boundary: {task}")
    elif mode == 'live':
        if 'authorized live namespace' not in content or 'task-directed change' not in content:
            sys.exit(f"live tutorial lacks authorized task namespace workflow: {task}")
PYDOCS
total_points="$(awk -F '\t' 'NR>1 {sum+=$3} END {print sum}' metadata/tasks.tsv)"
grep -Fq "($total_points total configured points" README.md || fail "README score total mismatch"
grep -Fq 'SOLUTIONS.md' README.md || fail "README solution tutorial index missing"
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

python3 ./tests/task-lifecycle.py
python3 ./tests/review-regressions.py
python3 - <<'PYTEST'
import csv, pathlib, yaml, os
rows=list(csv.DictReader(open('metadata/tasks.tsv'),delimiter='\t'))
assert len(rows)==60
for row in rows:
    d=pathlib.Path('tasks')/row['domain']/row['id']
    assert (d/'task.md').is_file()
    for name in ('setup','teardown','score'):
        p=d/(name+'.sh')
        assert p.is_file() and os.access(p,os.X_OK),p
    seed=d/'resources/seed.yaml'
    if seed.exists():
        for doc in yaml.safe_load_all(seed.read_text()):
            assert doc['metadata']['namespace']=='__NAMESPACE__'
            assert doc['metadata']['labels']['cka-lab.io/owner']=='cka-talos-practice'
            assert doc['metadata']['labels']['cka-lab.io/task']==row['id']
for id, domain, required in [('N02','networking',{'estuary-api'}),
                             ('N10','networking',{'estuary-api','estuary-front'}),
                             ('W13','workloads',{'ember-api'}),
                             ('T05','troubleshooting',{'dns-stray','web'}),
                             ('T08','troubleshooting',{'web'}),
                             ('T10','troubleshooting',{'toolbox'})]:
    docs=list(yaml.safe_load_all((pathlib.Path('tasks')/domain/id/'resources/seed.yaml').read_text()))
    assert required <= {d['metadata']['name'] for d in docs}
assert not (pathlib.Path('tasks/storage/S05/resources/seed.yaml')).exists()
assert next(row for row in rows if row['id']=='T10')['mode']=='live'
t08=list(yaml.safe_load_all((pathlib.Path('tasks/troubleshooting/T08/resources/seed.yaml')).read_text()))
assert len(t08)==1 and t08[0]['kind']=='Deployment'
assert t08[0]['spec']['template']['metadata']['labels']['cka-lab.io/task']=='T08'
t10=list(yaml.safe_load_all((pathlib.Path('tasks/troubleshooting/T10/resources/seed.yaml')).read_text()))
assert len(t10)==1 and t10[0]['kind']=='Pod'
print('ok: all 60 executable task directories, isolated seeds and standalone prerequisites')
PYTEST
CKA_LAB_PREFIX=cka-practice CKA_LAB_NAMESPACE=cka-practice bash -c 'source lib/common.sh; validate_scope'
if CKA_LAB_PREFIX=bad_prefix CKA_LAB_NAMESPACE=bad_prefix bash -c 'source lib/common.sh; validate_scope' >/dev/null 2>&1; then fail "unsafe scope accepted"; fi
printf 'ok: safety invariants\nall static tests passed\n'
