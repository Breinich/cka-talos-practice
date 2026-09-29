#!/usr/bin/env python3
"""Local fake API: interleaved task instances, fail-closed ownership/storage."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
MOCK = r'''#!/usr/bin/env python3
import json,os,sys,yaml
from pathlib import Path
p=Path(os.environ['FAKE_API']);data=json.loads(p.read_text());args=sys.argv[1:]
def save():p.write_text(json.dumps(data))
def fail():print('Error from server (NotFound): not found',file=sys.stderr);sys.exit(1)
if args[:2]==['config','current-context']:print(os.environ.get('FAKE_CONTEXT','admin@lake'))
elif args[:2]==['config','view']:print(os.environ.get('FAKE_SERVER','https://lab.example:6443'))
elif args[0]=='cluster-info':print('lab')
elif args[0]=='api-resources':
 if '--namespaced=true' in args:print('pods\ndeployments.apps\nservices')
elif args[:2]==['get','namespace']:
 n=args[2];print(json.dumps(data['ns'][n])) if n in data['ns'] else fail()
elif args[:2]==['get','node']:
 if os.environ.get('FAKE_NODE')=='true':print(json.dumps({'status':{'nodeInfo':{'containerRuntimeVersion':'containerd://2.0'}}}))
 else:fail()
elif args[:2]==['get','persistentvolumeclaims']:print(json.dumps({'items':data.get('pvc',{}).get(args[args.index('-n')+1],[])}))
elif args[:2]==['get','persistentvolumes']:print(json.dumps({'items':data.get('pv',[])}))
elif args[0]=='get' and args[1] in ('pods','deployments.apps','services'):
 ns=args[args.index('-n')+1]; kind=args[1].split('.')[0].rstrip('s');print(json.dumps({'items':[v for k,v in data['items'].get(ns,{}).items() if k.startswith(kind+'/')]}))
elif args[0]=='get' and '-n' in args:
 ns=args[args.index('-n')+1];kind=args[1].split('.')[0].rstrip('s');key=kind+'/'+args[2]
 print(json.dumps(data['items'].get(ns,{}).get(key))) if key in data['items'].get(ns,{}) else fail()
elif args[:2]==['create','-f']:
 d=yaml.safe_load(sys.stdin.read());n=d['metadata']['name'];assert n not in data['ns']
 d['metadata']['uid']='uid-'+n;data['ns'][n]=d;data['items'][n]={};save()
elif args[:2]==['apply','-f']:
 ns=None
 for d in yaml.safe_load_all(sys.stdin.read()):
  if d is None:continue
  ns=d['metadata']['namespace'];d['metadata']['uid']='uid-'+ns+'-'+d['metadata']['name'];kind=d['kind'].lower();data['items'][ns][kind+'/'+d['metadata']['name']]=d
 save()
elif args[:2]==['delete','pod']:
 n=args[args.index('-n')+1];data['items'][n].pop('pod/'+args[2]);save()
elif args[:2]==['delete','namespace']:
 n=args[2];data['ns'].pop(n);data['items'].pop(n);save()
elif args[:2]==['top','nodes'] and os.environ.get('FAKE_METRICS')=='true':
 print('NAME CPU(cores) CPU% MEMORY(bytes) MEMORY%\nnode-1 12m 1% 20Mi 1%')
elif args[:2]==['top','pods'] and os.environ.get('FAKE_METRICS')=='true':
 print('NAME CPU(cores) MEMORY(bytes)\nweb-abc 5m 16Mi')
elif args[0] in ('rollout','set','auth','top'):sys.exit(1)
else:sys.exit(1)
'''


def score(id, env):
    result = subprocess.run([str(ROOT / 'scripts/score.sh'), id, '--json'], cwd='/tmp',
                            env=env, capture_output=True, text=True)
    return json.loads(result.stdout)['tasks'][0]['status']


def run(script, id, env, *args, ok=True):
    proc = subprocess.run([str(ROOT / 'scripts' / script), id, *args], cwd='/tmp',
                          env=env, capture_output=True, text=True)
    assert (proc.returncode == 0) == ok, (script, id, proc.stderr)
    return proc


with tempfile.TemporaryDirectory() as tmp:
    base = Path(tmp); bin = base / 'bin'; bin.mkdir()
    kubectl = bin / 'kubectl'; kubectl.write_text(MOCK); kubectl.chmod(0o755)
    talosctl = bin / 'talosctl'
    talosctl.write_text('#!/usr/bin/env bash\n[[ "${FAKE_TALOS:-}" == true ]] || exit 1\nif [[ "$*" == "get members -o json" ]]; then echo "{}"; else echo "STATE Running"; fi\n')
    talosctl.chmod(0o755)
    api = base / 'api.json'; api.write_text(json.dumps({'ns': {}, 'items': {}}))
    env = dict(os.environ, PATH=f'{bin}:{os.environ["PATH"]}', FAKE_API=str(api),
               CKA_TASK_STATE_ROOT=str(base / 'state'))
    run('setup.sh', 'W01', env)
    run('setup.sh', 'N01', env)
    data = json.loads(api.read_text()); assert set(data['ns']) == {'cka-practice-w01', 'cka-practice-n01'}
    assert set(data['items']['cka-practice-w01']) == {'deployment/ember-api'}
    assert set(data['items']['cka-practice-n01']) == {'deployment/estuary-api', 'service/estuary-front'}
    run('setup.sh', 'W01', env)  # idempotent single-task reseed
    run('teardown.sh', 'W01', env)
    data = json.loads(api.read_text()); assert set(data['ns']) == {'cka-practice-n01'}
    run('teardown.sh', 'W01', env, ok=False)  # missing state refuses
    # Labelled pre-existing namespaces must never be adopted or deleted.
    data['ns']['cka-practice-w01'] = {'metadata':{'uid':'foreign','name':'cka-practice-w01',
        'labels':{'cka-lab.io/owner':'cka-talos-practice','cka-lab.io/task':'W01','cka-lab.io/prefix':'cka-practice'}}}
    api.write_text(json.dumps(data))
    run('setup.sh', 'W01', env, ok=False)
    run('teardown.sh', 'W01', env, ok=False)
    data=json.loads(api.read_text());data['ns'].pop('cka-practice-w01');api.write_text(json.dumps(data))
    # Alternate prefix and namespace; context drift blocks even --yes.
    run('setup.sh', 'W02', env, '--prefix', 'alternate', '--namespace', 'alternate-example')
    switched=dict(env, FAKE_SERVER='https://other.example:6443')
    run('teardown.sh', 'W02', switched, '--yes', '--prefix', 'alternate', '--namespace', 'alternate-example', ok=False)
    data=json.loads(api.read_text());data['pvc']={'alternate-example':[{'metadata':{'name':'unlabelled'}}]};api.write_text(json.dumps(data))
    run('teardown.sh', 'W02', env, '--prefix', 'alternate', '--namespace', 'alternate-example', ok=False)
    w02=base/'state/W02/alternate-example/evidence';(w02/'notes.txt').write_text('retain on blocked reset')
    run('reset.sh', 'W02', env, '--prefix', 'alternate', '--namespace', 'alternate-example', ok=False)
    assert (w02/'notes.txt').read_text() == 'retain on blocked reset'
    data=json.loads(api.read_text());data['pvc']={};data['pv']=[{'spec':{'claimRef':{'namespace':'alternate-example'}}}];api.write_text(json.dumps(data))
    run('teardown.sh', 'W02', env, '--yes', '--prefix', 'alternate', '--namespace', 'alternate-example', ok=False)
    data=json.loads(api.read_text());data['pv']=[]
    data['items']['alternate-example']['pod/other']={'kind':'Pod','metadata':{'name':'other','uid':'uid-other',
        'labels':{'cka-lab.io/owner':'cka-talos-practice','cka-lab.io/task':'W01'}}}
    api.write_text(json.dumps(data))
    run('teardown.sh', 'W02', env, '--prefix', 'alternate', '--namespace', 'alternate-example', ok=False)
    data=json.loads(api.read_text());data['items']['alternate-example'].pop('pod/other');api.write_text(json.dumps(data))
    run('teardown.sh', 'W02', env, '--prefix', 'alternate', '--namespace', 'alternate-example')
    run('teardown.sh', 'N01', env)
    run('setup.sh', 'A08', env)
    overlay = base / 'state/A08/cka-practice-a08/A08-kustomize/overlay/kustomization.yaml'
    assert overlay.is_file()
    overlay.write_text(overlay.read_text() + '\n# learner edit\n')
    run('setup.sh', 'A08', env)
    assert '# learner edit' in overlay.read_text()
    run('teardown.sh', 'A08', env)
    run('setup.sh', 'W10', env)
    assert (base / 'state/W10/cka-practice-w10/evidence/W10-overlay/hpa.yaml').is_file()
    run('teardown.sh', 'W10', env)
    assert json.loads(api.read_text())['ns'] == {}
    # T08 metrics require both a namespaced web Pod and a real matching top row.
    metrics = dict(env, FAKE_METRICS='true')
    run('setup.sh', 'T08', metrics)
    data=json.loads(api.read_text())
    assert set(data['items']['cka-practice-t08']) == {'deployment/web'}
    t08=base/'state/T08/cka-practice-t08'
    (t08/'capabilities.env').write_text('METRICS=true\n')
    (t08/'evidence/T08.sh').write_text('kubectl top nodes\nkubectl top pods -n "$CKA_LAB_NAMESPACE"\n')
    (t08/'evidence/T08.json').write_text(json.dumps({'node':'node-1','namespace':'cka-practice-t08','pod':'web-abc'}))
    assert score('T08', metrics) == 'PARTIAL'  # top row alone is not a Pod
    data['items']['cka-practice-t08']['pod/web-abc']={'kind':'Pod','metadata':{'uid':'web-pod',
        'name':'web-abc','namespace':'cka-practice-t08','labels':{'app':'web',
        'cka-lab.io/owner':'cka-talos-practice','cka-lab.io/task':'T08'}},'status':{'phase':'Running'}}
    api.write_text(json.dumps(data))
    assert score('T08', metrics) == 'PASS'
    prior=json.loads((t08/'state.json').read_text())['instance']
    run('reset.sh', 'T08', metrics)
    assert not (t08/'evidence/T08.json').exists()
    assert json.loads((t08/'state.json').read_text())['instance'] != prior
    assert score('T08', metrics) == 'SKIP'  # fake API cannot confirm metrics on reseed
    run('teardown.sh', 'T08', metrics)
    # T10 is live (a dedicated toolbox) but Talos access remains capability gated.
    run('setup.sh', 'T10', env)
    data=json.loads(api.read_text()); assert set(data['items']['cka-practice-t10']) == {'pod/toolbox'}
    assert score('T10', env) == 'UNSUPPORTED'
    talos=dict(env, FAKE_TALOS='true', FAKE_NODE='true')
    run('setup.sh', 'T10', talos)
    t10=base/'state/T10/cka-practice-t10'
    assert 'TALOSCTL=true' in (t10/'capabilities.env').read_text()
    assert score('T10', talos) == 'FAIL'  # no evidence yet
    data=json.loads(api.read_text());data['items']['cka-practice-t10']['pod/toolbox']['spec']['nodeName']='node-1'
    data['items']['cka-practice-t10']['pod/toolbox']['status']={'phase':'Running'};api.write_text(json.dumps(data))
    (t10/'evidence/T10.json').write_text(json.dumps({'node':'node-1','runtimeVersion':'containerd://2.0',
        'podRuntimeClass':'','kubeletService':'Running','containerdService':'Running'}))
    assert score('T10', talos) == 'PASS'
    data=json.loads(api.read_text());data['items']['cka-practice-t10']['pod/toolbox']['spec']['nodeName']='wrong';api.write_text(json.dumps(data))
    assert score('T10', talos) == 'FAIL'
    run('teardown.sh', 'T10', talos)
    # Offline fresh attempt removes only that instance's evidence, never a peer's.
    offline=dict(env, FAKE_SERVER='')
    run('setup.sh', 'A11', offline)
    run('setup.sh', 'A11', offline, '--namespace', 'cka-practice-peer')
    run('setup.sh', 'A07', offline)
    default=base/'state/A11/cka-practice-a11/evidence'
    peer=base/'state/A11/cka-practice-peer/evidence'
    other=base/'state/A07/cka-practice-a07/evidence'
    good={'healthyMembers':2,'quorum':2,'snapshotUsable':True,'restoreAllowedNow':False,
          'firstAction':'investigate-member','snapshotPath':'/secure/snapshots/cedar.db'}
    for path in (default, peer): (path/'A11.json').write_text(json.dumps(good))
    (other/'A07-rendered.yaml').write_text('keep this task')
    assert score('A11', offline)=='PASS'
    saved=default.parent/'saved-evidence'
    default.rename(saved);default.symlink_to(peer, target_is_directory=True)
    run('reset.sh', 'A11', offline, ok=False)
    assert (peer/'A11.json').exists() and (other/'A07-rendered.yaml').exists()
    default.unlink();saved.rename(default)
    run('reset.sh', 'A11', offline)
    assert score('A11', offline)=='FAIL'
    assert not (default/'A11.json').exists()
    assert (peer/'A11.json').exists() and (other/'A07-rendered.yaml').exists()
    assert score('A11', dict(offline, CKA_LAB_NAMESPACE='cka-practice-peer'))=='PASS'
    assert json.loads(api.read_text())['ns']=={}
print('ok: independent task lifecycles, T08/T10 capability and real-row scoring, offline/live reset isolation and storage guards')
