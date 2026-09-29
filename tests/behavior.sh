#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/state/evidence"
cp "$ROOT/tests/mock-kubectl.sh" "$tmp/bin/kubectl"
chmod +x "$tmp/bin/kubectl"
export PATH="$tmp/bin:$PATH" CKA_LAB_STATE_DIR="$tmp/state" MOCK_LOG="$tmp/log"
assert_score() {
  local task="$1" status="$2" rc=0 out
  out="$("$ROOT/scripts/validate.sh" --task "$task" --json)" || rc=$?
  python3 - "$out" "$status" "$rc" <<'PY'
import json,sys
score=json.loads(sys.argv[1]); task=score['tasks'][0]
assert task['status']==sys.argv[2], task
assert (int(sys.argv[3])==0)==(sys.argv[2] in ('PASS','SKIP')), (task, sys.argv[3])
assert not (task['status']=='PARTIAL' and task['score']==task['max']), task
PY
}
export MOCK_MODE=score
printf 'port-forward\n' >"$tmp/state/evidence/N10.txt"
assert_score N10 PARTIAL
printf '{"healthyMembers":2,"quorum":2,"snapshotUsable":true,"restoreAllowedNow":true,"firstAction":"restore","snapshotPath":"/secure/snapshots/cedar.db"}\n' >"$tmp/state/evidence/A11.json"
assert_score A11 PARTIAL
printf '{"healthyMembers":2,"quorum":2,"snapshotUsable":true,"restoreAllowedNow":false,"firstAction":"investigate-member","snapshotPath":"/secure/snapshots/cedar.db"}\n' >"$tmp/state/evidence/A11.json"
assert_score A11 PASS
printf '{"members":3,"healthyMembers":2,"quorum":2,"survivesAnotherFailure":true,"apiEndpoint":"api.lab.example.test:6443","endpointInSANs":true,"replacementZone":"west","membershipMutationAllowedNow":false,"nextStep":"restore-elm-health"}\n' >"$tmp/state/evidence/A17.json"
assert_score A17 PARTIAL
sed -i 's/"survivesAnotherFailure":true/"survivesAnotherFailure":false/' "$tmp/state/evidence/A17.json"
assert_score A17 PASS
printf '{"group":"telemetry.example.test","scope":"Namespaced","plural":"signals","servedVersions":["v1alpha1","v1"],"storageVersion":"v1alpha1","resourcePath":"/apis/telemetry.example.test/v1alpha1/namespaces/cka-practice/signals"}\n' >"$tmp/state/evidence/A06.json"
assert_score A06 PARTIAL
sed -i 's@v1alpha1/namespaces@v1/namespaces@;s/"storageVersion":"v1alpha1"/"storageVersion":"v1"/' "$tmp/state/evidence/A06.json"
assert_score A06 PASS
python3 - "$ROOT/scripts/check_resource.py" <<'PYTEST'
import json, subprocess, sys
script=sys.argv[1]
def accepts(mode, obj):
    return subprocess.run([sys.executable, script, mode], input=json.dumps(obj), text=True, capture_output=True).returncode==0
role={'metadata':{'labels':{'cka-lab.io/owner':'cka-talos-practice'}},'rules':[{'apiGroups':[''],'resources':['pods'],'verbs':['get','list','watch']}]}
assert accepts('arch-role',role)
role['rules'][0]['resources'].append('secrets')
assert not accepts('arch-role',role)
binding={'metadata':{'namespace':'cka-practice','labels':{'cka-lab.io/owner':'cka-talos-practice'}},'roleRef':{'apiGroup':'rbac.authorization.k8s.io','kind':'Role','name':'relay-reader'},'subjects':[{'kind':'ServiceAccount','name':'relay-identity','namespace':'cka-practice'}]}
assert accepts('arch-binding',binding)
binding['subjects'][0]['namespace']='other'
assert not accepts('arch-binding',binding)
pod={'metadata':{'labels':{'app':'signal-operator','cka-lab.io/owner':'cka-talos-practice'}},'spec':{'serviceAccountName':'relay-identity','automountServiceAccountToken':False,'containers':[{'image':'busybox:1.36','command':['sleep','7d']}]}}
assert accepts('arch-pod',pod)
pod['spec']['automountServiceAccountToken']=True
assert not accepts('arch-pod',pod)
print('ok: architecture RBAC and Pod near misses rejected')
PYTEST
# Offline architecture scorers must reject plausible but wrong rendered manifests.
python3 - "$ROOT" "$tmp/state/evidence" <<'PYTEST'
import os, sys, subprocess, yaml
from pathlib import Path
root=Path(sys.argv[1]); evidence=Path(sys.argv[2]); script=root/'scripts/check_architecture.py'
env=dict(os.environ)
def accepts(task,criterion):
    return subprocess.run([sys.executable,str(script),task,str(criterion)],env=env,capture_output=True).returncode==0
render={'apiVersion':'apps/v1','kind':'Deployment','metadata':{'name':'harbor-relay-relay','namespace':'cka-practice','labels':{'cka-lab.io/owner':'cka-talos-practice'}},'spec':{'replicas':2,'selector':{'matchLabels':{'app':'harbor-relay-relay'}},'template':{'metadata':{'labels':{'app':'harbor-relay-relay','cka-lab.io/owner':'cka-talos-practice'}},'spec':{'containers':[{'name':'relay','image':'nginx:1.27-alpine'}]}}}}
path=evidence/'A07-rendered.yaml';path.write_text(yaml.safe_dump(render))
assert accepts('A07',1) and accepts('A07',2)
render['spec']['selector']['matchLabels']['app']='wrong';path.write_text(yaml.safe_dump(render))
assert accepts('A07',1) and not accepts('A07',2)
crd=list(yaml.safe_load_all((root/'samples/architecture/crd.yaml').read_text()))[0]
crd['metadata']['labels']={'cka-lab.io/owner':'cka-talos-practice','cka-lab.io/prefix':'cka-practice'}
sa={'apiVersion':'v1','kind':'ServiceAccount','metadata':{'name':'signal-operator'}}
role={'apiVersion':'rbac.authorization.k8s.io/v1','kind':'Role','metadata':{'name':'signal-operator'},'rules':[{'apiGroups':['telemetry.example.test'],'resources':['signals'],'verbs':['get','list','watch']}]}
binding={'apiVersion':'rbac.authorization.k8s.io/v1','kind':'RoleBinding','metadata':{'name':'signal-operator'},'roleRef':{'apiGroup':'rbac.authorization.k8s.io','kind':'Role','name':'signal-operator'},'subjects':[{'kind':'ServiceAccount','name':'signal-operator','namespace':'cka-practice'}]}
deploy={'apiVersion':'apps/v1','kind':'Deployment','metadata':{'name':'signal-operator'},'spec':{'replicas':1,'selector':{'matchLabels':{'app':'signal-operator'}},'template':{'metadata':{'labels':{'app':'signal-operator','cka-lab.io/owner':'cka-talos-practice'}},'spec':{'serviceAccountName':'signal-operator','containers':[{'image':'busybox:1.36'}]}}}}
resource={'kind':'Signal','apiVersion':'telemetry.example.test/v1','metadata':{'name':'harbor-signal'}}
for doc in (sa,role,binding,deploy,resource):
    doc['metadata'].update({'namespace':'cka-practice','labels':{'cka-lab.io/owner':'cka-talos-practice'}})
docs=[crd,sa,role,binding,deploy,resource]
path=evidence/'A16-operator.yaml';path.write_text(yaml.safe_dump_all(docs))
assert accepts('A16',1) and accepts('A16',2)
role['rules'][0]['resources']=['secrets'];path.write_text(yaml.safe_dump_all(docs))
assert accepts('A16',1) and not accepts('A16',2)
print('ok: Helm render and offline operator exact/near-miss criteria')
PYTEST
# Real kubectl kustomize is local-only and gives a positive/negative overlay check.
python3 - "$ROOT" "$tmp/state/evidence" <<'PYTEST'
import os, subprocess, sys
from pathlib import Path
root=Path(sys.argv[1]); evidence=Path(sys.argv[2]); overlay=evidence/'A18-overlay';overlay.mkdir()
(overlay/'component.yaml').write_text((root/'samples/architecture/component.yaml').read_text())
(overlay/'kustomization.yaml').write_text('resources:\n- component.yaml\nnamespace: cka-practice\nreplicas:\n- name: collector-agent\n  count: 2\nlabels:\n- pairs:\n    cka-lab.io/owner: cka-talos-practice\n  includeTemplates: true\n')
env=dict(os.environ,PATH='/usr/bin:/bin')
manifest=subprocess.check_output(['kubectl','kustomize',str(overlay)],env=env)
(evidence/'A18-component.yaml').write_bytes(manifest)
def accepts(part):
    return subprocess.run([sys.executable,str(root/'scripts/check_architecture.py'),'A18',str(part)],env=env,capture_output=True).returncode==0
assert accepts(1) and accepts(2)
(overlay/'kustomization.yaml').write_text((overlay/'kustomization.yaml').read_text().replace('count: 2','count: 3'))
assert accepts(1) and not accepts(2)
print('ok: local component overlay/render agreement and near miss')
PYTEST
# Namespace/prefix override affects the expected namespaced API path, not just task prose.
CKA_LAB_PREFIX=harbor CKA_LAB_NAMESPACE=harbor-zone python3 - "$ROOT" "$tmp/state/evidence" <<'PYTEST'
import json,os,subprocess,sys
from pathlib import Path
p=Path(sys.argv[2])/'A06.json';e=json.loads(p.read_text());e['resourcePath']='/apis/telemetry.example.test/v1/namespaces/harbor-zone/signals';p.write_text(json.dumps(e))
r=subprocess.run([sys.executable,str(Path(sys.argv[1])/'scripts/check_architecture.py'),'A06','2'],env=os.environ,capture_output=True)
assert r.returncode==0,r.stderr
print('ok: architecture namespace override')
PYTEST
export NETWORKPOLICY=true
printf 'NETWORKPOLICY=true\nGATEWAY=true\n' >"$tmp/state/capabilities.env"
assert_score N05 FAIL
assert_score W04 FAIL
assert_score W05 SKIP
assert_score W10 SKIP
assert_score N01 PARTIAL
assert_score N08 PARTIAL
assert_score T04 PARTIAL
assert_score N07 PARTIAL
export MOCK_MODE=positive
assert_score W04 FAIL
assert_score W05 SKIP
assert_score W10 SKIP
assert_score N01 PASS
assert_score N08 PASS
assert_score T04 PASS
assert_score N07 PASS
printf 'allow success; deny timeout\n' >"$tmp/state/evidence/N05.txt"
assert_score N05 PASS
if grep -Eq '^(apply|delete|create|label)' "$tmp/log"; then echo 'mock scorer mutated resources' >&2; exit 1; fi
printf 'ok: mocked scorer partial, near-misses, EndpointSlice, route and positive criteria\n'

export MOCK_MODE=collision
if "$ROOT/scripts/setup.sh" >"$tmp/out" 2>&1; then echo 'fixture collision accepted' >&2; exit 1; fi
grep -q 'fixture collision' "$tmp/out"
[[ ! -f "$tmp/state/state.env" ]]
if grep -Eq '^(apply|delete|create|label)' "$tmp/log"; then echo 'collision mutated resources' >&2; exit 1; fi
export MOCK_MODE=setup
"$ROOT/scripts/setup.sh" >"$tmp/out" 2>&1
baseline="$(sha256sum "$tmp/state/before.yaml")"
"$ROOT/scripts/setup.sh" >"$tmp/out" 2>&1
[[ "$(sha256sum "$tmp/state/before.yaml")" == "$baseline" ]]
grep -q 'rollout status deployment/ember-recovery' "$tmp/log"
grep -q 'set image deployment/ember-recovery api=nginx:no-such-tag-cka-practice' "$tmp/log"
python3 - "$tmp/state/before.yaml" <<'PY'
import json,sys
items=json.load(open(sys.argv[1]))['items']
assert [obj['metadata']['name'] for obj in items]==['owned-existing','web-route'], items
assert 'resourceVersion' not in items[0]['metadata']
assert 'status' not in items[1]
PY
export MOCK_MODE=restore
"$ROOT/scripts/restore.sh" >"$tmp/out" 2>&1
# Owned selector only, optional HTTPRoute included, unowned never in saved manifest.
grep -q 'delete .*cka-lab.io/owner=cka-talos-practice' "$tmp/log"
grep -q 'delete httproute.gateway.networking.k8s.io' "$tmp/log"
! grep -q 'delete .*persistentvolumeclaim' "$tmp/log"
printf 'ok: mocked existing-namespace restore preserves unowned and restores owned including optional routes\n'
python3 - "$tmp/state/before.yaml" <<'PYTEST'
import json,sys
p=sys.argv[1]; data=json.load(open(p)); data['items'][0]['metadata']['labels']['cka-lab.io/owner']='other'
with open(p,'w') as f: json.dump(data,f)
PYTEST
before="$(wc -l <"$tmp/log")"
if "$ROOT/scripts/restore.sh" >"$tmp/out" 2>&1; then echo 'unowned baseline accepted' >&2; exit 1; fi
tail -n +"$((before+1))" "$tmp/log" | grep -E '^(delete|apply)' >/dev/null && { echo 'invalid baseline caused mutation' >&2; exit 1; }
printf 'ok: invalid baseline rejected before mutation\n'
export MOCK_MODE=storage
before="$(wc -l <"$tmp/log")"
if "$ROOT/scripts/restore.sh" >"$tmp/out" 2>&1; then echo 'storage refusal missing' >&2; exit 1; fi
grep -q 'persistentvolumeclaim/data' "$tmp/out"
tail -n +"$((before+1))" "$tmp/log" | grep -E '^(delete|apply)' >/dev/null && { echo 'storage refusal mutated resources' >&2; exit 1; }
if "$ROOT/scripts/teardown.sh" >"$tmp/out" 2>&1; then echo 'teardown storage refusal missing' >&2; exit 1; fi
printf 'ok: storage guard refuses restore and teardown before mutation\n'
sed -i 's/NAMESPACE_EXISTED=true/NAMESPACE_EXISTED=false/' "$tmp/state/state.env"
export MOCK_MODE=unowned
if "$ROOT/scripts/teardown.sh" >"$tmp/out" 2>&1; then echo 'unowned namespace deletion accepted' >&2; exit 1; fi
grep -q 'refusing namespace deletion' "$tmp/out"
printf 'ok: teardown rejects unowned namespaced objects\n'

# Gateway capability requires a genuinely eligible, accepted/programmed listener.
python3 - "$ROOT/scripts/check_resource.py" <<'PYTEST'
import json, subprocess, sys
script=sys.argv[1]
gateway={"spec":{"listeners":[{"name":"http","protocol":"HTTP","allowedRoutes":{"namespaces":{"from":"Same"}}}]},"status":{"conditions":[{"type":"Programmed","status":"True"}],"listeners":[{"name":"http","conditions":[{"type":"Accepted","status":"True"},{"type":"Programmed","status":"True"}]}]}}
def accepts(g):
    return subprocess.run([sys.executable,script,"gateway"],input=json.dumps(g),text=True,capture_output=True).returncode==0
assert accepts(gateway)
gateway['spec']['listeners'][0]['allowedRoutes']['namespaces']['from']='Selector'
assert not accepts(gateway)
gateway['spec']['listeners'][0]['allowedRoutes']['namespaces']['from']='Same'
gateway['status']['listeners'][0]['conditions'][0]['status']='False'
assert not accepts(gateway)
print('ok: gateway listener capability positive/negative checks')
PYTEST
python3 - "$ROOT/scripts/snapshot.py" <<'PYTEST'
import json, os, subprocess, sys
os.environ['OWNED_SERVICES']='web'
objects=[{'kind':'ConfigMap','metadata':{'name':'kube-root-ca.crt'}},
         {'apiVersion':'v1','kind':'ServiceAccount','metadata':{'name':'default'}},
         {'kind':'EndpointSlice','metadata':{'name':'web-abc','labels':{'endpointslice.kubernetes.io/managed-by':'endpointslice-controller.k8s.io','kubernetes.io/service-name':'web'}}}]
def accepts():
    return subprocess.run([sys.executable,sys.argv[1],'--assert-owned'],input=json.dumps({'kind':'List','items':objects}),text=True,capture_output=True).returncode==0
assert accepts()
objects[-1]['metadata']['labels']['kubernetes.io/service-name']='other'
assert not accepts()
print('ok: generated namespace defaults and owned-service EndpointSlices handled conservatively')
PYTEST
