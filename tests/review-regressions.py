#!/usr/bin/env python3
"""A02 JWT lifetime, W05 mixed worker eligibility, actual A07 Helm render."""
import base64
import datetime
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def call(path, id, part, env):
    return subprocess.run([sys.executable, str(path), id, str(part)], env=env,
                          capture_output=True).returncode == 0


with tempfile.TemporaryDirectory() as tmp:
    temp = Path(tmp); (temp / 'evidence').mkdir(); (temp / 'bin').mkdir()
    kubectl = temp / 'bin' / 'kubectl'
    kubectl.write_text('''#!/usr/bin/env python3
import json,sys
args=sys.argv[1:]
if args[:2] == ['config','view']:
 print(json.dumps({'clusters':[{'cluster':{'server':'https://lab.example'}}]}))
elif args[:2] == ['get','nodes']:
 print(json.dumps({'items':[{'metadata':{'name':'ready'},'status':{'conditions':[{'type':'Ready','status':'True'}]}},
 {'metadata':{'name':'tainted'},'spec':{'taints':[{'effect':'NoSchedule'}]},'status':{'conditions':[{'type':'Ready','status':'True'}]}}]}))
else:sys.exit(1)
''')
    kubectl.chmod(0o755)
    env = dict(os.environ, PATH=f'{temp / "bin"}:{os.environ["PATH"]}',
               CKA_LAB_STATE_DIR=str(temp), CKA_LAB_NAMESPACE='cka-practice-a02')
    now = int(datetime.datetime.now(datetime.timezone.utc).timestamp())
    def token(seconds):
        body = base64.urlsafe_b64encode(json.dumps({'iat':now,'exp':now+seconds}).encode()).rstrip(b'=').decode()
        return f'header.{body}.signature'
    cfg = {'current-context':'ctx','clusters':[{'name':'c','cluster':{
        'server':'https://lab.example','certificate-authority-data':'ZHVtbXk='}}],
        'users':[{'name':'u','user':{'token':token(600)}}],
        'contexts':[{'name':'ctx','context':{'cluster':'c','user':'u','namespace':'cka-practice-a02'}}]}
    import yaml
    file = temp / 'evidence' / 'A02.kubeconfig'; file.write_text(yaml.safe_dump(cfg)); file.chmod(0o600)
    script = ROOT / 'scripts/check_architecture.py'
    assert call(script,'A02',1,env)
    cfg['users'][0]['user']['token']=token(3600);file.write_text(yaml.safe_dump(cfg))
    assert not call(script,'A02',1,env)
    file.chmod(0o644);assert not call(script,'A02',1,env)
    worker = subprocess.run([sys.executable,str(ROOT/'scripts/check_workloads.py'),'workers','1'],
        input=subprocess.check_output([str(kubectl),'get','nodes','-o','json']),env=env,capture_output=True)
    assert worker.returncode == 0 and worker.stdout.strip() == b'1'
    gated=subprocess.run([str(ROOT/'scripts/validate.sh'),'--task','W05','--json'],env=env,
                         capture_output=True,text=True)
    assert json.loads(gated.stdout)['tasks'][0]['status']=='FAIL', gated.stderr
    print('ok: 10-minute A02 token accepted, long-lived/loose-mode rejected without token output; W05 mixed workers count 1 and does not SKIP')

helm = shutil.which('helm')
if helm:
    with tempfile.TemporaryDirectory() as tmp:
        chart=ROOT/'tasks/architecture/A07/resources/chart'
        rendered=subprocess.check_output([helm,'template','harbor-relay',str(chart),'-n','cka-practice-a07',
                                          '--set','replicas=2'],text=True)
        state=Path(tmp)/'evidence';state.mkdir();(state/'A07-rendered.yaml').write_text(rendered)
        env=dict(os.environ,CKA_LAB_STATE_DIR=tmp,CKA_LAB_NAMESPACE='cka-practice-a07',
                 CKA_TASK_RESOURCES=str(chart.parent))
        assert call(ROOT/'scripts/check_architecture.py','A07',1,env)
        assert call(ROOT/'scripts/check_architecture.py','A07',2,env)
        print('ok: actual Helm template A07 render passes both scorer criteria')
else:
    print('SKIP: actual Helm template regression (helm not installed)')
