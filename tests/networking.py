#!/usr/bin/env python3
"""Offline positive/near-miss scoring for every networking prompt and overridden namespace."""
import copy
import json
import os
from pathlib import Path
import subprocess
import tempfile
import yaml

ROOT = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory() as tmp:
    root = Path(tmp)
    evidence = root / 'evidence'
    evidence.mkdir()
    ns = 'estuary-zone'
    env = dict(os.environ, CKA_LAB_PREFIX='estuary', CKA_LAB_NAMESPACE=ns, CKA_LAB_STATE_DIR=tmp)
    fixture = list(yaml.safe_load_all((ROOT / 'fixtures/base/networking.yaml').read_text().replace('__NAMESPACE__', ns)))
    deploy, front, catalog, port = fixture
    deploy['status'] = {'readyReplicas': 1}
    for svc in (front, catalog, port):
        svc['spec']['selector'] = {'app': 'estuary-api', 'cka-lab.io/owner': 'cka-talos-practice'}
        svc['spec']['ports'][0]['targetPort'] = 'http'
        svc['spec']['clusterIP'] = '10.96.12.21'
    peers = copy.deepcopy(front)
    peers['metadata']['name'] = 'estuary-peers'
    peers['spec']['clusterIP'] = 'None'
    objs = {('deployment', 'estuary-api'): deploy, **{('service', o['metadata']['name']): o for o in (front, catalog, port, peers)}}
    slices = {name: {'items': [{'ports': [{'name': 'http', 'port': 80}], 'endpoints': [{'conditions': {'ready': True}, 'addresses': ['10.4.0.8']}]}]} for name in ('estuary-front', 'estuary-catalog', 'estuary-port', 'estuary-peers')}
    pods = {'items':[{'metadata':{'labels':{'app':'estuary-api','cka-lab.io/owner':'cka-talos-practice'}}, 'status':{'podIP':'10.4.0.8','phase':'Running','conditions':[{'type':'Ready','status':'True'}]}}]}
    (root / 'objects.json').write_text(json.dumps({'objects': {f'{k}/{n}': v for (k, n), v in objs.items()}, 'slices': slices, 'pods':pods}))
    bin_dir = root / 'bin'
    bin_dir.mkdir()
    kubectl = bin_dir / 'kubectl'
    kubectl.write_text('''#!/usr/bin/env python3
import json,os,sys
s=json.load(open(os.environ['CKA_LAB_STATE_DIR']+'/objects.json'))
a=sys.argv[1:]
if a[0]!='get': sys.exit(1)
if a[1]=='endpointslice': print(json.dumps(s['slices'].get(a[a.index('-l')+1].split('=',1)[1],{'items':[]})))
elif a[1]=='pods': print(json.dumps(s['pods']))
else: print(json.dumps(s['objects'][a[1]+'/'+a[2]]))
''')
    kubectl.chmod(0o755)
    env['PATH'] = str(bin_dir) + ':' + env['PATH']
    def score(task, part):
        return subprocess.run(['python3', str(ROOT / 'scripts/check_networking.py'), task, str(part)], env=env, capture_output=True).returncode == 0
    def save(name, docs):
        (evidence / name).write_text(yaml.safe_dump_all(docs))
    def owned(kind, name, spec, api='v1'):
        return {'apiVersion': api, 'kind': kind, 'metadata': {'name': name, 'namespace': ns, 'labels': {'cka-lab.io/owner': 'cka-talos-practice'}}, 'spec': spec}
    for task in ('N01', 'N02', 'N03', 'N08'):
        assert score(task, 1) and score(task, 2), task
    data = json.loads((root / 'objects.json').read_text())
    data['objects']['service/estuary-front']['spec']['selector'] = {'app': 'wrong'}
    (root / 'objects.json').write_text(json.dumps(data))
    assert not score('N01', 1) and not score('N01', 2)
    data['objects']['service/estuary-front']['spec']['selector'] = {'app': 'estuary-api', 'cka-lab.io/owner': 'cka-talos-practice'}
    data['slices']['estuary-catalog']['items'][0]['endpoints'][0]['conditions']['ready'] = False
    data['objects']['service/estuary-port']['spec']['ports'][0]['targetPort'] = 81
    data['objects']['service/estuary-peers']['spec']['clusterIP'] = '10.96.2.8'
    (root / 'objects.json').write_text(json.dumps(data))
    assert score('N03', 1) and not score('N03', 2)
    assert not score('N08', 1) and not score('N08', 2)
    assert not score('N02', 1) and not score('N02', 2)
    data['objects']['service/estuary-port']['spec']['ports'][0]['targetPort'] = 'http'
    data['slices']['estuary-catalog']['items'][0]['endpoints'][0]['conditions']['ready'] = True
    data['slices']['estuary-catalog']['items'][0]['endpoints'][0]['addresses'] = ['10.4.0.9']
    (root / 'objects.json').write_text(json.dumps(data))
    assert score('N03',1) and not score('N03',2), 'unrelated EndpointSlice address credited'
    data['slices']['estuary-catalog']['items'][0]['endpoints'][0]['addresses'] = ['10.4.0.8']
    data['objects']['service/estuary-peers']['spec']['clusterIP'] = 'None'
    (root / 'objects.json').write_text(json.dumps(data))
    def evidence_json(name, good, bad):
        path = evidence / name
        path.write_text(json.dumps(good))
        return path, lambda: path.write_text(json.dumps({**good, **bad}))
    path, bad = evidence_json('N04-dns.json', {'query':'estuary-front','qualifiedName':f'estuary-front.{ns}.svc.cluster.local','resolvedAddress':'10.96.12.21','otherServiceAddress':'10.96.12.22','reason':'namespace-search'}, {'resolvedAddress':'10.96.12.99'})
    assert score('N04',1) and score('N04',2)
    bad(); assert score('N04',1) and not score('N04',2)
    deny = owned('NetworkPolicy','estuary-egress-deny',{'podSelector':{'matchLabels':{'app':'toolbox','cka-lab.io/owner':'cka-talos-practice'}},'policyTypes':['Egress']},'networking.k8s.io/v1')
    dns = {'to':[{'namespaceSelector':{'matchLabels':{'kubernetes.io/metadata.name':'kube-system'}}}],'ports':[{'protocol':'UDP','port':53}]}
    api = {'to':[{'podSelector':{'matchLabels':{'app':'estuary-api','cka-lab.io/owner':'cka-talos-practice'}}}],'ports':[{'protocol':'TCP','port':80}]}
    allow = owned('NetworkPolicy','estuary-egress-allow',{'podSelector':{'matchLabels':{'app':'toolbox','cka-lab.io/owner':'cka-talos-practice'}},'policyTypes':['Egress'],'egress':[dns,api]},'networking.k8s.io/v1')
    save('N05-policy.yaml',[deny,allow]); assert score('N05',1) and score('N05',2)
    api['ports'][0]['port']=8080; save('N05-policy.yaml',[deny,allow]); assert score('N05',1) and not score('N05',2)
    api['ports'][0]['port']=80
    entry = owned('Ingress','estuary-entry',{'ingressClassName':'offline-estuary','rules':[{'host':'estuary.lab.invalid','http':{'paths':[{'path':'/v1','pathType':'Prefix','backend':{'service':{'name':'estuary-front','port':{'number':8080}}}}]}}]},'networking.k8s.io/v1')
    save('N06-ingress.yaml',[entry]); assert score('N06',1) and score('N06',2)
    entry['spec']['rules'][0]['http']['paths'][0]['backend']['service']['port']['number']=80
    save('N06-ingress.yaml',[entry]); assert score('N06',1) and not score('N06',2)
    route = owned('HTTPRoute','estuary-route',{'hostnames':['estuary.lab.invalid'],'parentRefs':[{'name':'estuary-gateway','sectionName':'http'}], 'rules':[{'matches':[{'path':{'type':'PathPrefix','value':'/v1'},'headers':[{'name':'x-estuary-tier','value':'canary','type':'Exact'}]}],'backendRefs':[{'name':'estuary-port','port':8080}]},{'matches':[{'path':{'type':'PathPrefix','value':'/v1'}}],'backendRefs':[{'name':'estuary-front','port':8080}]}]},'gateway.networking.k8s.io/v1')
    save('N07-route.yaml',[route]); assert score('N07',1) and score('N07',2)
    route['spec']['rules'].reverse(); save('N07-route.yaml',[route]); assert score('N07',1) and not score('N07',2)
    path,bad=evidence_json('N09-incident.json',{'plugin':'kubernetes','zone':'cluster.local','name':f'estuary-front.{ns}.svc.cluster.local','blockedTransport':'UDP','blockedPort':53,'repairScope':'client-egress-policy'},{'repairScope':'coredns-corefile'})
    assert score('N09',1) and score('N09',2)
    bad(); assert score('N09',1) and not score('N09',2)
    path,bad=evidence_json('N10-forward.json',{'namespace':ns,'service':'estuary-front','localPort':18080,'remotePort':8080,'httpStatus':200,'body':'Welcome to nginx!'},{'httpStatus':404})
    assert score('N10',1) and score('N10',2)
    bad(); assert score('N10',1) and not score('N10',2)
    node=owned('Service','estuary-node-demo',{'type':'NodePort','selector':{'app':'estuary-api'},'ports':[{'name':'http','port':8080,'targetPort':'http','nodePort':30081}]})
    alias=owned('Service','estuary-alias-demo',{'type':'ExternalName','externalName':'estuary.lab.invalid'})
    save('N11-services.yaml',[node,alias]); assert score('N11',1) and score('N11',2)
    alias['spec']['externalName']='wrong.invalid';save('N11-services.yaml',[node,alias]);assert score('N11',1) and not score('N11',2)
    print('ok: N01-N11 positive and wrong-selector, endpoint, targetPort, routing, policy, DNS, exposure near misses with namespace override')
