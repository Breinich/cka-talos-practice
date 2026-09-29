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
elif args[:2]==['delete','namespace']:
 n=args[2];data['ns'].pop(n);data['items'].pop(n);save()
elif args[0] in ('rollout','set','auth','top'):sys.exit(1)
else:sys.exit(1)
'''


def run(script, id, env, *args, ok=True):
    proc = subprocess.run([str(ROOT / 'scripts' / script), id, *args], cwd='/tmp',
                          env=env, capture_output=True, text=True)
    assert (proc.returncode == 0) == ok, (script, id, proc.stderr)
    return proc


with tempfile.TemporaryDirectory() as tmp:
    base = Path(tmp); bin = base / 'bin'; bin.mkdir()
    kubectl = bin / 'kubectl'; kubectl.write_text(MOCK); kubectl.chmod(0o755)
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
    # Offline setup must not invoke kubectl even with an invalid kubeconfig.
    run('setup.sh', 'A07', dict(env, FAKE_SERVER=''), ok=True)
print('ok: independent mock task lifecycles, re-seed, identity, unowned and storage guards')
