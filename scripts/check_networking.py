#!/usr/bin/env python3
"""Read-only structural and observable networking criteria; no cluster mutations."""
import json
import os
from pathlib import Path
import subprocess
import sys

import yaml

TASK, PART = sys.argv[1], int(sys.argv[2])
NS = os.environ.get('CKA_LAB_NAMESPACE', os.environ.get('CKA_LAB_PREFIX', 'cka-practice'))
E = Path(os.environ.get('CKA_LAB_STATE_DIR', Path(__file__).resolve().parents[1] / '.lab')) / 'evidence'
OWNER = 'cka-talos-practice'


def get(kind, name):
    return json.loads(subprocess.check_output(['kubectl', 'get', kind, name, '-n', NS, '-o', 'json'], stderr=subprocess.DEVNULL))


def slices(service):
    data = json.loads(subprocess.check_output(['kubectl', 'get', 'endpointslice', '-n', NS, '-l', 'kubernetes.io/service-name=' + service, '-o', 'json'], stderr=subprocess.DEVNULL))
    return data.get('items', [])


def endpoint(service):
    deploy = get('deployment', 'estuary-api')
    assert deploy['spec']['selector']['matchLabels'] == {'app': 'estuary-api'}
    assert deploy.get('status', {}).get('readyReplicas', 0) >= 1
    pods = json.loads(subprocess.check_output(['kubectl', 'get', 'pods', '-n', NS, '-l', 'app=estuary-api', '-o', 'json'], stderr=subprocess.DEVNULL))
    ready = {p.get('status', {}).get('podIP') for p in pods.get('items', [])
             if p.get('metadata', {}).get('labels', {}).get('cka-lab.io/owner') == OWNER
             and p.get('status', {}).get('phase') == 'Running'
             and any(c.get('type') == 'Ready' and c.get('status') == 'True' for c in p.get('status', {}).get('conditions', []))}
    ready.discard(None)
    return bool(ready) and any(s.get('ports') and any(p.get('name') == 'http' and p.get('port') == 80 for p in s['ports'])
               and any(e.get('conditions', {}).get('ready') is True and any(a in ready for a in e.get('addresses', [])) for e in s.get('endpoints', []))
               for s in slices(service))


def service(name, headless=False):
    s = get('service', name)
    spec = s['spec']
    return (s['metadata'].get('labels', {}).get('cka-lab.io/owner') == OWNER
            and spec.get('selector') == {'app': 'estuary-api', 'cka-lab.io/owner': OWNER}
            and spec.get('type', 'ClusterIP') == 'ClusterIP'
            and (spec.get('clusterIP') == 'None' if headless else bool(spec.get('clusterIP')) and spec['clusterIP'] != 'None')
            and len(spec.get('ports', [])) == 1
            and spec['ports'][0].get('name') == 'http'
            and spec['ports'][0].get('port') == 8080
            and spec['ports'][0].get('targetPort') == 'http')


def docs(name):
    result = list(yaml.safe_load_all((E / name).read_text()))
    assert result and all(isinstance(x, dict) for x in result)
    return result


def scoped(o, kind, name):
    m = o.get('metadata', {})
    return o.get('kind') == kind and m.get('name') == name and m.get('namespace') == NS and m.get('labels', {}).get('cka-lab.io/owner') == OWNER


def ingress():
    d, = docs('N06-ingress.yaml')
    assert scoped(d, 'Ingress', 'estuary-entry') and d.get('apiVersion') == 'networking.k8s.io/v1'
    return d


def route():
    d, = docs('N07-route.yaml')
    assert scoped(d, 'HTTPRoute', 'estuary-route') and d.get('apiVersion') == 'gateway.networking.k8s.io/v1'
    return d


def backend(r, name):
    return r.get('backendRefs') == [{'name': name, 'port': 8080}]


def rules():
    deny, allow = docs('N05-policy.yaml')
    assert scoped(deny, 'NetworkPolicy', 'estuary-egress-deny') and scoped(allow, 'NetworkPolicy', 'estuary-egress-allow')
    assert deny.get('apiVersion') == allow.get('apiVersion') == 'networking.k8s.io/v1'
    assert deny['spec'] == {'podSelector': {'matchLabels': {'app': 'toolbox', 'cka-lab.io/owner': OWNER}}, 'policyTypes': ['Egress']}
    assert allow['spec'].get('podSelector') == {'matchLabels': {'app': 'toolbox', 'cka-lab.io/owner': OWNER}}
    assert allow['spec'].get('policyTypes') == ['Egress']
    return allow['spec'].get('egress', [])


def single_egress(rule, peer, proto, port):
    return rule.get('to') == [peer] and rule.get('ports') == [{'protocol': proto, 'port': port}]


def check():
    if TASK in ('N01', 'N02', 'N03', 'N08'):
        name = {'N01': 'estuary-front', 'N02': 'estuary-peers', 'N03': 'estuary-catalog', 'N08': 'estuary-port'}[TASK]
        return service(name, TASK == 'N02') if PART == 1 else endpoint(name) and service(name, TASK == 'N02')
    if TASK == 'N04':
        o = json.loads((E / 'N04-dns.json').read_text())
        return (o.get('query') == 'estuary-front' and o.get('qualifiedName') == f'estuary-front.{NS}.svc.cluster.local') if PART == 1 else (o.get('resolvedAddress') == '10.96.12.21' and o.get('otherServiceAddress') == '10.96.12.22' and o.get('reason') == 'namespace-search')
    if TASK == 'N05':
        ruleset = rules()
        if PART == 1:
            return len(ruleset) == 2 and any(single_egress(r, {'namespaceSelector': {'matchLabels': {'kubernetes.io/metadata.name': 'kube-system'}}}, 'UDP', 53) for r in ruleset)
        return len(ruleset) == 2 and any(single_egress(r, {'podSelector': {'matchLabels': {'app': 'estuary-api', 'cka-lab.io/owner': OWNER}}}, 'TCP', 80) for r in ruleset)
    if TASK == 'N06':
        d = ingress(); spec = d['spec']
        if PART == 1:
            return len(spec.get('rules', [])) == 1 and spec['rules'][0].get('host') == 'estuary.lab.invalid' and spec.get('ingressClassName') == 'offline-estuary'
        paths = spec['rules'][0].get('http', {}).get('paths', [])
        return len(paths) == 1 and paths[0] == {'path': '/v1', 'pathType': 'Prefix', 'backend': {'service': {'name': 'estuary-front', 'port': {'number': 8080}}}}
    if TASK == 'N07':
        d = route(); spec = d['spec']; rr = spec.get('rules', [])
        if PART == 1:
            return spec.get('hostnames') == ['estuary.lab.invalid'] and spec.get('parentRefs') == [{'name': 'estuary-gateway', 'sectionName': 'http'}]
        return (len(rr) == 2 and rr[0].get('matches') == [{'path': {'type': 'PathPrefix', 'value': '/v1'}, 'headers': [{'name': 'x-estuary-tier', 'value': 'canary', 'type': 'Exact'}]}]
                and backend(rr[0], 'estuary-port') and rr[1].get('matches') == [{'path': {'type': 'PathPrefix', 'value': '/v1'}}] and backend(rr[1], 'estuary-front'))
    if TASK == 'N09':
        o = json.loads((E / 'N09-incident.json').read_text())
        return (o.get('plugin') == 'kubernetes' and o.get('zone') == 'cluster.local' and o.get('name') == f'estuary-front.{NS}.svc.cluster.local') if PART == 1 else (o.get('blockedTransport') == 'UDP' and o.get('blockedPort') == 53 and o.get('repairScope') == 'client-egress-policy')
    if TASK == 'N10':
        o = json.loads((E / 'N10-forward.json').read_text())
        return (o.get('namespace') == NS and o.get('service') == 'estuary-front' and o.get('localPort') == 18080 and o.get('remotePort') == 8080 and service('estuary-front')) if PART == 1 else (o.get('httpStatus') == 200 and 'Welcome to nginx!' in o.get('body', '') and endpoint('estuary-front'))
    if TASK == 'N11':
        a, b = docs('N11-services.yaml')
        assert scoped(a, 'Service', 'estuary-node-demo') and scoped(b, 'Service', 'estuary-alias-demo')
        if PART == 1:
            return (a['spec'].get('type') == 'NodePort' and a['spec'].get('selector') == {'app': 'estuary-api'} and a['spec'].get('ports') == [{'name': 'http', 'port': 8080, 'targetPort': 'http', 'nodePort': 30081}])
        return b['spec'] == {'type': 'ExternalName', 'externalName': 'estuary.lab.invalid'}
    return False


try:
    sys.exit(0 if check() else 1)
except (KeyError, ValueError, OSError, subprocess.CalledProcessError, AssertionError, TypeError, yaml.YAMLError):
    sys.exit(1)
