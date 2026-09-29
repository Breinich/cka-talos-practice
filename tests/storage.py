#!/usr/bin/env python3
"""Storage end-state tests are offline; no real kubectl or storage API calls."""
import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

import yaml

ROOT = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory() as tmp:
    base = Path(tmp)
    evidence = base / 'evidence'
    evidence.mkdir()
    bin_dir = base / 'bin'
    bin_dir.mkdir()
    mock = bin_dir / 'kubectl'
    mock.write_text('''#!/usr/bin/env python3
import json,os,sys
args=sys.argv[1:]
if args[0]=='exec':
    sys.stdout.write(os.environ.get('MOCK_RECEIPT',''))
else:
    objects=json.load(open(os.environ['MOCK_STORAGE_JSON']))
    key=args[1]+('/'+args[2] if args[2] not in ('-n','-o') else '')
    if key not in objects: sys.exit(1)
    print(json.dumps(objects[key]))
''')
    mock.chmod(0o755)
    objects_path = base / 'objects.json'
    env = dict(os.environ, PATH=str(bin_dir) + ':' + os.environ['PATH'], CKA_LAB_STATE_DIR=tmp,
               CKA_LAB_PREFIX='harbor', CKA_LAB_NAMESPACE='harbor-zone',
               CKA_LAB_STORAGE_CLASS='disposable-csi', MOCK_STORAGE_JSON=str(objects_path),
               MOCK_RECEIPT='lighthouse-ready\n')

    def accepts(task, part, objects=None):
        objects_path.write_text(json.dumps(objects or {}))
        return subprocess.run([sys.executable, str(ROOT/'scripts/check_storage.py'), task, str(part)],
                              env=env, capture_output=True).returncode == 0

    def render(name):
        return (ROOT/'samples/storage'/name).read_text().replace('__PREFIX__','harbor').replace('__NAMESPACE__','harbor-zone')

    docs=list(yaml.safe_load_all(render('static-broken.yaml')))
    docs[1]['spec']['accessModes']=['ReadWriteOnce']
    docs[1]['spec']['resources']['requests']['storage']='256Mi'
    docs[2]['spec']['volumes'][0]['persistentVolumeClaim']['claimName']='lighthouse-archive'
    (evidence/'S02-static.yaml').write_text(yaml.safe_dump_all(docs))
    assert accepts('S02',1) and accepts('S02',2)
    bad=copy.deepcopy(docs);bad[1]['spec']['resources']['requests']['storage']='512Mi'
    (evidence/'S02-static.yaml').write_text(yaml.safe_dump_all(bad))
    assert not accepts('S02',1) and not accepts('S02',2)
    bad=copy.deepcopy(docs);bad[2]['spec']['volumes'][0]['persistentVolumeClaim']['claimName']='other'
    (evidence/'S02-static.yaml').write_text(yaml.safe_dump_all(bad))
    assert accepts('S02',1) and not accepts('S02',2)
    bad=copy.deepcopy(docs);bad[0]['metadata']['labels']['cka-lab.io/prefix']='wrong'
    (evidence/'S02-static.yaml').write_text(yaml.safe_dump_all(bad))
    assert not accepts('S02',1)
    records=list(yaml.safe_load_all(render('reclaim-broken.yaml')))
    records[1]['spec']['accessModes']=['ReadWriteOnce']
    records[0]['spec']['persistentVolumeReclaimPolicy']='Retain'
    (evidence/'S06-reclaim.yaml').write_text(yaml.safe_dump_all(records))
    assert accepts('S06',1) and accepts('S06',2)
    records[0]['spec']['persistentVolumeReclaimPolicy']='Delete'
    (evidence/'S06-reclaim.yaml').write_text(yaml.safe_dump_all(records))
    assert accepts('S06',1) and not accepts('S06',2)
    records[1]['spec']['accessModes']=['ReadOnlyMany']
    (evidence/'S06-reclaim.yaml').write_text(yaml.safe_dump_all(records))
    assert not accepts('S06',1)

    owner={'cka-lab.io/owner':'cka-talos-practice'}
    deployment={'metadata':{'labels':owner,'generation':2},'spec':{'replicas':1,'template':{'spec':{'volumes':[{'name':'workspace','emptyDir':{}}],
       'containers':[{'name':n,'volumeMounts':[{'name':'workspace','mountPath':'/workspace'}]} for n in ('producer','consumer')]}}},
       'status':{'observedGeneration':2,'readyReplicas':1}}
    pod={'metadata':{'labels':dict(owner,app='lighthouse-workspace'),'ownerReferences':[{'kind':'ReplicaSet'}],'name':'lighthouse-workspace-abc'},
         'status':{'phase':'Running','containerStatuses':[{'name':n,'ready':True} for n in ('producer','consumer')]}}
    objects={'deployment/lighthouse-workspace':deployment,'pods':{'items':[pod]}}
    assert accepts('S01',1,objects) and accepts('S01',2,objects)
    bad=copy.deepcopy(objects);bad['deployment/lighthouse-workspace']['spec']['template']['spec']['containers'][1]['volumeMounts']=[]
    assert not accepts('S01',1,bad) and not accepts('S01',2,bad)
    bad=copy.deepcopy(objects);bad['deployment/lighthouse-workspace']['status']['readyReplicas']=0
    assert accepts('S01',1,bad) and not accepts('S01',2,bad)
    env['MOCK_RECEIPT']='wrong'
    assert not accepts('S01',2,objects)
    env['MOCK_RECEIPT']='lighthouse-ready\n'

    pvc={'metadata':{'labels':owner},'spec':{'storageClassName':'disposable-csi','accessModes':['ReadWriteOnce'],
         'resources':{'requests':{'storage':'64Mi'}}},'status':{'phase':'Bound','capacity':{'storage':'64Mi'}}}
    reader={'metadata':{'labels':owner},'spec':{'volumes':[{'name':'data','persistentVolumeClaim':{'claimName':'lighthouse-live'}}],
            'containers':[{'name':'reader','volumeMounts':[{'name':'data','mountPath':'/data'}]}]},
            'status':{'phase':'Running','containerStatuses':[{'name':'reader','ready':True}]}}
    objects={'pvc/lighthouse-live':pvc,'pod/lighthouse-live-reader':reader}
    env['MOCK_RECEIPT']='lighthouse-live-ready\n'
    assert accepts('S03',1,objects) and accepts('S03',2,objects)
    assert not accepts('S05',1,objects)
    pvc['spec']['resources']['requests']['storage']='128Mi'
    assert not accepts('S05',1,objects)
    pvc['status']['capacity']['storage']='134217728'
    assert accepts('S05',1,objects) and accepts('S05',2,objects) and not accepts('S03',1,objects)
    env['MOCK_RECEIPT']='wrong'
    assert accepts('S05',1,objects) and not accepts('S05',2,objects)
    env['MOCK_RECEIPT']='lighthouse-live-ready\n'
    bad=copy.deepcopy(objects);bad['pvc/lighthouse-live']['spec']['resources']['requests']['storage']='1Gi'
    assert not accepts('S05',1,bad)
    bad=copy.deepcopy(objects);bad['pvc/lighthouse-live']['spec']['storageClassName']='other'
    assert not accepts('S03',1,bad) and not accepts('S05',1,bad)
    bad=copy.deepcopy(objects);bad['pod/lighthouse-live-reader']['spec']['volumes'][0]['persistentVolumeClaim']['claimName']='wrong'
    assert accepts('S05',1,bad) and not accepts('S05',2,bad)

    classes=[{'metadata':{'name':'disposable-csi','annotations':{'storageclass.kubernetes.io/is-default-class':'true'}},
              'provisioner':'example.test/csi','reclaimPolicy':'Delete','volumeBindingMode':'WaitForFirstConsumer','allowVolumeExpansion':True}]
    inventory={'classes':[{'name':'disposable-csi','provisioner':'example.test/csi','reclaimPolicy':'Delete',
                            'volumeBindingMode':'WaitForFirstConsumer','allowVolumeExpansion':True,'isDefault':True}],
               'drivers':['example.test/csi']}
    (evidence/'S04.json').write_text(json.dumps(inventory))
    objects={'storageclass':{'items':classes},'csidriver':{'items':[{'metadata':{'name':'example.test/csi'}}]}}
    assert accepts('S04',1,objects) and accepts('S04',2,objects)
    inventory['classes'][0]['isDefault']=False
    (evidence/'S04.json').write_text(json.dumps(inventory))
    assert not accepts('S04',1,objects) and accepts('S04',2,objects)
    inventory['drivers']=[]
    (evidence/'S04.json').write_text(json.dumps(inventory))
    assert not accepts('S04',2,objects)
print('ok: storage offline/live exact criteria and near misses, including scope overrides')
