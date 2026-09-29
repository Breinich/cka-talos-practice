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
assert (int(sys.argv[3])==0)==(sys.argv[2]=='PASS'), (task, sys.argv[3])
assert not (task['status']=='PARTIAL' and task['score']==task['max']), task
PY
}
export MOCK_MODE=score
printf 'port-forward\n' >"$tmp/state/evidence/N10.txt"
assert_score N10 PARTIAL
printf 'snapshot restore\n' >"$tmp/state/evidence/A11.txt"
assert_score A11 FAIL
printf 'snapshot encrypted backup verify integrity; restore quorum endpoints precondition rollback\n' >"$tmp/state/evidence/A11.txt"
assert_score A11 PASS
export NETWORKPOLICY=true
printf 'NETWORKPOLICY=true\nGATEWAY=true\n' >"$tmp/state/capabilities.env"
assert_score N05 FAIL
assert_score W04 FAIL
assert_score W05 PARTIAL
assert_score N01 PARTIAL
assert_score N08 PARTIAL
assert_score T04 PARTIAL
assert_score N07 PARTIAL
export MOCK_MODE=positive
assert_score W04 PASS
assert_score W05 PASS
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
tail -n +"$((before+1))" "$tmp/log" | grep -Eq '^(delete|apply)' && { echo 'invalid baseline caused mutation' >&2; exit 1; }
printf 'ok: invalid baseline rejected before mutation\n'
export MOCK_MODE=storage
before="$(wc -l <"$tmp/log")"
if "$ROOT/scripts/restore.sh" >"$tmp/out" 2>&1; then echo 'storage refusal missing' >&2; exit 1; fi
grep -q 'persistentvolumeclaim/data' "$tmp/out"
tail -n +"$((before+1))" "$tmp/log" | grep -Eq '^(delete|apply)' && { echo 'storage refusal mutated resources' >&2; exit 1; }
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
         {'kind':'ServiceAccount','metadata':{'name':'default'}},
         {'kind':'EndpointSlice','metadata':{'name':'web-abc','labels':{'endpointslice.kubernetes.io/managed-by':'endpointslice-controller.k8s.io','kubernetes.io/service-name':'web'}}}]
def accepts():
    return subprocess.run([sys.executable,sys.argv[1],'--assert-owned'],input=json.dumps({'kind':'List','items':objects}),text=True,capture_output=True).returncode==0
assert accepts()
objects[-1]['metadata']['labels']['kubernetes.io/service-name']='other'
assert not accepts()
print('ok: generated namespace defaults and owned-service EndpointSlices handled conservatively')
PYTEST
