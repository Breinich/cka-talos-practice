#!/usr/bin/env python3
"""Mocked kubectl: each workload criterion accepts the target and rejects a near miss."""
import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

import yaml

root = Path(__file__).resolve().parent.parent
ns = 'harbor-zone'
owner = {'cka-lab.io/owner': 'cka-talos-practice'}
with tempfile.TemporaryDirectory() as temp:
    temp = Path(temp)
    bin = temp / 'bin'; bin.mkdir()
    (bin / 'kubectl').write_text('''#!/usr/bin/env python3
import json,sys,os
from pathlib import Path
args=sys.argv[1:]; objects=json.loads(Path(os.environ['WORKLOAD_MOCK']).read_text())
if args[0]=='kustomize':
 print(json.dumps(objects['hpa/ember-autoscale']));sys.exit(0)
if args[:2]==['rollout','history']:
 print('REVISION CHANGE-CAUSE\\n1 <none>\\n2 <none>');sys.exit(0)
if args[:2]==['get','nodes'] or args[:2]==['get','pods']:
 print(json.dumps(objects.get('get nodes' if args[1]=='nodes' else 'get pods -l', {'items':[]})));sys.exit(0)
if len(args)>2 and args[0]=='get':
 obj=objects.get(args[1]+'/'+args[2]);
 if obj is not None: print(json.dumps(obj));sys.exit(0)
sys.exit(1)
''')
    (bin / 'kubectl').chmod(0o755)
    env = dict(os.environ, PATH=str(bin) + ':' + os.environ['PATH'], CKA_LAB_PREFIX='harbor',
               CKA_LAB_NAMESPACE=ns, CKA_LAB_STATE_DIR=str(temp), WORKLOAD_MOCK=str(temp / 'objects.json'))
    (temp / 'evidence').mkdir()
    docs = list(yaml.safe_load_all((root / 'fixtures/base/workloads.yaml').read_text().replace('__NAMESPACE__', ns)))
    objects = {o['kind'].lower() + '/' + o['metadata']['name']: o for o in docs}
    def put(kind, name, spec, status=None):
        obj={'metadata':{'name':name,'namespace':ns,'labels':dict(owner),'generation':1},'spec':spec,'status': status or {}}
        objects[kind+'/'+name]=obj
        return obj
    def deployed(name, n):
        obj=objects['deployment/'+name]
        obj['status']={'observedGeneration':1,'readyReplicas':n}
    deployed('ember-api',2)
    api=objects['deployment/ember-api'];api['spec']['replicas']=2
    api['spec']['template']['spec']['containers'][0]['resources']['requests']={'cpu':'20m','memory':'32Mi'}
    release=objects['deployment/ember-release'];release['spec']['template']['spec']['containers'][0]['image']='nginx:1.27-alpine'
    deployed('ember-release',2);deployed('ember-recovery',1)
    ledger=objects['statefulset/ember-ledger'];ledger['spec']['replicas']=2
    ledger['status']={'observedGeneration':1,'readyReplicas':2}
    objects['service/ember-ledger']['spec']['clusterIP']='None'
    # API defaulted strategy is returned as normalized Kubernetes JSON.
    nodes={'items':[{'metadata':{'name':n},'status':{'conditions':[{'type':'Ready','status':'True'}]}} for n in ('worker-a','worker-b')]}
    objects['get nodes']=nodes
    def pods(label, names):
        objects['get pods -l']={'items':[{'metadata':{'name':name,'labels':dict(owner)},'spec':{'nodeName':node},'status':{'phase':'Running'}} for name,node in names]}
    put('job','ember-batch',{'completions':1,'parallelism':1,'template':{'metadata':{'labels':dict(owner)},'spec':{'restartPolicy':'Never','containers':[{'image':'busybox:1.36','command':['sh','-c','echo report-ready']}]}}}, {'conditions':[{'type':'Complete','status':'True'}]})
    put('cronjob','ember-timer',{'schedule':'*/10 * * * *','suspend':True,'successfulJobsHistoryLimit':1,'failedJobsHistoryLimit':1,'jobTemplate':{'spec':{'template':{'metadata':{'labels':dict(owner)},'spec':{'restartPolicy':'Never','containers':[{'image':'busybox:1.36','command':['sh','-c','echo timer-ready']}]}}}}})
    ds=put('daemonset','ember-observer',{'selector':{'matchLabels':{'app':'ember-observer'}},'template':{'metadata':{'labels':{'app':'ember-observer',**owner}},'spec':{'nodeSelector':{'node-role.kubernetes.io/worker':''},'containers':[{'image':'busybox:1.36','command':['sh','-c','sleep 7d'],'resources':{'requests':{'cpu':'5m','memory':'8Mi'}}}]}}},{'desiredNumberScheduled':2,'numberReady':2})
    put('configmap','ember-settings',{},None)['data']={'MODE':'audit'}
    secret=put('secret','ember-token',{});secret.update({'type':'Opaque','data':{'TOKEN':'ZHVtbXk='}})
    def pod(name, ps):
        obj=put('pod',name,ps,{'phase':'Running','conditions':[{'type':'Ready','status':'True'}]})
        return obj
    pod('ember-consumer',{'containers':[{'image':'busybox:1.36','command':['sh','-c','sleep 7d'],'env':[{'name':'MODE','valueFrom':{'configMapKeyRef':{'name':'ember-settings','key':'MODE'}}},{'name':'TOKEN','valueFrom':{'secretKeyRef':{'name':'ember-token','key':'TOKEN'}}}]}]})
    placement=objects['deployment/ember-placement'];placement['spec']['template']['spec']['affinity']={'nodeAffinity':{'requiredDuringSchedulingIgnoredDuringExecution':{'nodeSelectorTerms':[{'matchExpressions':[{'key':'node-role.kubernetes.io/worker','operator':'Exists'}]}]}},'podAntiAffinity':{'requiredDuringSchedulingIgnoredDuringExecution':[{'labelSelector':{'matchLabels':{'app':'ember-placement'}},'topologyKey':'kubernetes.io/hostname'}]}}
    deployed('ember-placement',2)
    hpa=put('hpa','ember-autoscale',{'scaleTargetRef':{'apiVersion':'apps/v1','kind':'Deployment','name':'ember-autoscale'},'minReplicas':1,'maxReplicas':3,'metrics':[{'type':'Resource','resource':{'name':'cpu','target':{'type':'Utilization','averageUtilization':60}}}]},{'conditions':[{'type':'AbleToScale','status':'True'}]})
    hpa['kind']='HorizontalPodAutoscaler'
    guard=pod('ember-guard',{'containers':[{'image':'busybox:1.36','command':['httpd','-f','-p','8080'],'readinessProbe':{'tcpSocket':{'port':8080}},'livenessProbe':{'tcpSocket':{'port':8080}},'securityContext':{'runAsUser':10001,'allowPrivilegeEscalation':False}}]})
    mount=[{'name':'shared','mountPath':'/shared'}]
    init={'name':'prepare','image':'busybox:1.36','volumeMounts':mount,'command':['sh','-c','echo ready > /shared/seed']}
    main={'name':'main','image':'busybox:1.36','volumeMounts':mount,'command':['sh','-c','test -f /shared/seed && sleep 7d']}
    side={'name':'sidecar','image':'busybox:1.36','volumeMounts':mount,'command':['sh','-c','sleep 7d']}
    composed=pod('ember-composed',{'volumes':[{'name':'shared','emptyDir':{}}],'initContainers':[init],'containers':[main,side]})
    pdb=put('poddisruptionbudget','ember-api',{'minAvailable':1,'selector':{'matchLabels':{'app':'ember-api'}}},{'currentHealthy':2,'disruptionsAllowed':1})
    simulated={'kind':'Pod','metadata':{'name':'ember-isolate'},'spec':{'nodeSelector':{'kubernetes.io/hostname':'oak-a'},'tolerations':[{'key':'training.example.test/isolated','operator':'Equal','value':'yes','effect':'NoSchedule'}],'containers':[{'image':'busybox:1.36','resources':{'requests':{'cpu':'5m','memory':'8Mi'}}}]}}
    def check(task, part):
        (temp / 'objects.json').write_text(json.dumps(objects))
        (temp / 'evidence/W09-pod.yaml').write_text(yaml.safe_dump(simulated))
        return subprocess.run([sys.executable,str(root/'scripts/check_workloads.py'),task,str(part)],env=env,capture_output=True)
    misses={
        'W01':[(api['spec'],'replicas',1),(api['status'],'readyReplicas',1)],
        'W02':[(release['spec']['template']['spec']['containers'][0],'image','nginx:1.26-alpine'),(release['status'],'readyReplicas',1)],
        'W03':[(objects['deployment/ember-recovery']['spec']['template']['spec']['containers'][0],'image','nginx:broken'),(objects['deployment/ember-recovery']['status'],'readyReplicas',0)],
        'W04':[(objects['job/ember-batch']['spec'],'parallelism',2),(objects['cronjob/ember-timer']['spec'],'suspend',False)],
        'W05':[(ds['spec']['template']['spec']['containers'][0]['resources']['requests'],'cpu','500m'),(ds['status'],'numberReady',1)],
        'W06':[(ledger['spec'],'replicas',3),(ledger['status'],'readyReplicas',1)],
        'W07':[(secret['data'],'TOKEN','d3Jvbmc='),(objects['pod/ember-consumer']['status'],'phase','Pending')],
        'W08':[(placement['spec']['template']['spec']['affinity']['podAntiAffinity'],'requiredDuringSchedulingIgnoredDuringExecution',[]),(placement['status'],'readyReplicas',1)],
        'W09':[(simulated['spec']['nodeSelector'],'kubernetes.io/hostname','oak-b'),(simulated['spec']['tolerations'][0],'operator','Exists')],
        'W10':[(hpa['spec'],'maxReplicas',4),(hpa['status']['conditions'][0],'status','False')],
        'W11':[(guard['spec']['containers'][0]['securityContext'],'allowPrivilegeEscalation',True),(guard['status'],'phase','Pending')],
        'W12':[(composed['spec']['volumes'][0],'name','other'),(composed['spec']['containers'][0],'command',['sleep','7d'])],
        'W13':[(pdb['spec'],'minAvailable',2),(pdb['status'],'disruptionsAllowed',0)],
    }
    for task in misses:
        for part,(target,key,bad) in enumerate(misses[task],1):
            if task in ('W05','W08'):
                pods('ember-observer' if task=='W05' else 'ember-placement', [('p1','worker-a'),('p2','worker-b')])
            if task=='W06': pods('ember-ledger', [('ember-ledger-0','worker-a'),('ember-ledger-1','worker-b')])
            result=check(task,part)
            assert result.returncode == 0,(task,part,result.stderr.decode())
            old=target[key];target[key]=bad
            result=check(task,part)
            assert result.returncode != 0,(task,part,'accepted near miss')
            target[key]=old
    print('ok: 26 mocked workload positives and 26 near misses with namespace override')
# Verify that the documented local overlay actually renders and that a wrong
# utilization survives rendering (the mock above exercises the live scorer).
with tempfile.TemporaryDirectory() as tmp:
    overlay = Path(tmp)
    sample = root / 'samples/workloads/hpa'
    (overlay / 'hpa.yaml').write_text((sample / 'hpa.yaml').read_text().replace('maxReplicas: 2', 'maxReplicas: 3').replace('averageUtilization: 80', 'averageUtilization: 60'))
    (overlay / 'kustomization.yaml').write_text((sample / 'kustomization.yaml').read_text() + 'namespace: harbor-zone\n')
    def render():
        return list(yaml.safe_load_all(subprocess.check_output(['/usr/bin/kubectl','kustomize',str(overlay)])))[0]
    hpa=render()
    assert hpa['metadata']['namespace']=='harbor-zone' and hpa['spec']['maxReplicas']==3
    assert hpa['spec']['metrics'][0]['resource']['target']['averageUtilization']==60
    (overlay / 'hpa.yaml').write_text((overlay / 'hpa.yaml').read_text().replace('averageUtilization: 60','averageUtilization: 80'))
    assert render()['spec']['metrics'][0]['resource']['target']['averageUtilization']!=60
    print('ok: real offline HPA overlay render and utilization near miss')
