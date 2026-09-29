#!/usr/bin/env python3
"""Read-only architecture checks. Return 1 on a mismatch; never print evidence."""
import datetime as dt
import base64
import ssl
import socket
import json
import os
import re
from pathlib import Path
import subprocess
import sys
from urllib.parse import urlparse

root = Path(__file__).resolve().parent.parent
state = Path(os.environ.get('CKA_LAB_STATE_DIR', root / '.lab')) / 'evidence'
ns = os.environ.get('CKA_LAB_NAMESPACE', os.environ.get('CKA_LAB_PREFIX', 'cka-practice'))
prefix = os.environ.get('CKA_LAB_PREFIX', 'cka-practice')
owner = 'cka-talos-practice'


def command(*args):
    return subprocess.check_output(args, stderr=subprocess.DEVNULL, text=True).strip()


def live(*args):
    return json.loads(command('kubectl', *args, '-o', 'json'))


def evidence(id):
    return json.loads((state / f'{id}.json').read_text())


def documents(path):
    import yaml
    return list(yaml.safe_load_all(path.read_text()))


def valid_scope(doc):
    return doc['metadata'].get('namespace') == ns and doc['metadata'].get('labels', {}).get('cka-lab.io/owner') == owner


def deployment(doc, name, replicas, image=None):
    spec = doc['spec']
    template = spec['template']
    return (doc.get('apiVersion') == 'apps/v1' and doc['kind'] == 'Deployment' and doc['metadata']['name'] == name
            and valid_scope(doc) and spec['replicas'] == replicas
            and template['metadata']['labels'].get('cka-lab.io/owner') == owner
            and (image is None or template['spec']['containers'][0]['image'] == image))


def check(id, part):
    if id == 'A01':
        e = evidence(id)
        if part == 1:
            return e['serverVersion'] == live('version')['serverVersion']['gitVersion']
        resources = command('kubectl', 'api-resources', '--namespaced=true', '-o', 'name').splitlines()
        roles = command('kubectl', 'api-resources', '--api-group=rbac.authorization.k8s.io', '-o', 'name').splitlines()
        return e['podNamespaced'] is True and 'pods' in resources and e['roleGroup'] == 'rbac.authorization.k8s.io' and 'roles.rbac.authorization.k8s.io' in roles
    if id == 'A02':
        f = state / 'A02.kubeconfig'
        if part == 1:
            cfg = documents(f)[0]
            current = cfg['current-context']
            context = next(x['context'] for x in cfg['contexts'] if x['name'] == current)
            cluster = next(x['cluster'] for x in cfg['clusters'] if x['name'] == context['cluster'])
            user = next(x['user'] for x in cfg['users'] if x['name'] == context['user'])
            server = live('config', 'view', '--minify')['clusters'][0]['cluster']['server']
            return (len(cfg['clusters']) == len(cfg['users']) == len(cfg['contexts']) == 1
                    and cluster['server'] == server and (cluster.get('certificate-authority-data') or cluster.get('certificate-authority'))
                    and context.get('namespace') == ns and user.get('token')
                    and not any(k in user for k in ('client-certificate-data', 'client-key-data', 'exec', 'auth-provider'))
                    and f.stat().st_mode & 0o077 == 0)
        identity = live('--kubeconfig', str(f), 'auth', 'whoami')['status']['userInfo']['username']
        return (identity == f'system:serviceaccount:{ns}:relay-identity'
                and live('--kubeconfig', str(f), 'get', 'pod', 'toolbox', '-n', ns)['metadata']['name'] == 'toolbox'
                and command('kubectl', '--kubeconfig', str(f), 'auth', 'can-i', 'delete', 'pods', '-n', ns) == 'no')
    if id == 'A06':
        e = evidence(id); crd = documents(root / 'samples/architecture/crd.yaml')[0]['spec']
        if part == 1:
            return all((e[k] == crd[v]) for k,v in [('group','group'),('scope','scope')]) and e['plural'] == crd['names']['plural']
        served = [v['name'] for v in crd['versions'] if v['served']]
        storage = next(v['name'] for v in crd['versions'] if v['storage'])
        return (e['servedVersions'] == served and e['storageVersion'] == storage
                and e['resourcePath'] == f"/apis/{crd['group']}/{storage}/namespaces/{ns}/{crd['names']['plural']}")
    if id == 'A07':
        docs = documents(state / 'A07-rendered.yaml')
        if len(docs) != 1: return False
        d = docs[0]
        if part == 1: return deployment(d, 'harbor-relay-relay', 2, 'nginx:1.27-alpine')
        expected = documents(root / 'samples/architecture/chart/values.yaml')[0]
        return (expected['image'] == d['spec']['template']['spec']['containers'][0]['image']
                and d['spec']['selector']['matchLabels'] == {'app': 'harbor-relay-relay'}
                and d['spec']['template']['metadata']['labels']['app'] == 'harbor-relay-relay')
    if id == 'A08':
        d = live('get','deployment',f'{prefix}-kustom-app','-n',ns)
        if part == 1: return deployment(d,f'{prefix}-kustom-app',2,'nginx:1.27-alpine')
        import yaml
        render = list(yaml.safe_load_all(command('kubectl','kustomize',str(root / 'fixtures/kustomize/overlay'))))
        return (len(render) == 1 and deployment(render[0],f'{prefix}-kustom-app',2,'nginx:1.27-alpine')
                and d['spec']['selector']['matchLabels'] == render[0]['spec']['selector']['matchLabels'])
    if id == 'A09':
        e = evidence(id)
        pods = live('get','pods','-n','kube-system')['items']
        prefixes = {'apiServerPods':'kube-apiserver-', 'schedulerPods':'kube-scheduler-',
                    'controllerPods':'kube-controller-manager-', 'etcdPods':'etcd-'}
        if part == 1:
            return all(sorted(e[k]) == sorted(p['metadata']['name'] for p in pods
                            if p['metadata']['name'].startswith(v)) for k,v in prefixes.items())
        observed = {p['spec']['nodeName'] for p in pods if p['spec'].get('nodeName')}
        return (e['apiServerEndpoint'] == urlparse(live('config','view','--minify')['clusters'][0]['cluster']['server']).hostname
                and sorted(e['observedNodes']) == sorted(observed) and bool(observed))
    if id == 'A10':
        e = evidence(id)
        members = command('talosctl','get','members','-o','json')
        if e['node'] not in members: return False
        if part == 1:
            health = subprocess.run(['talosctl','health','-n',e['node']],capture_output=True,timeout=15)
            return e['health'] == ('healthy' if health.returncode == 0 else 'unhealthy')
        services = command('talosctl','services','-n',e['node'])
        states = {}
        for line in services.splitlines():
            for name in ('kubelet','containerd'):
                if re.search(rf'\b{name}\b',line):
                    match = re.search(r'\b(running|stopped)\b',line,re.I)
                    if match: states[name] = match.group(1).lower()
        return (e['kubelet'] == states.get('kubelet') and e['containerd'] == states.get('containerd')
                and len(e['observation']) > 20 and e['observation'] in services)
    if id == 'A11':
        source = json.loads((root / 'samples/architecture/restore.json').read_text())
        e = evidence(id); healthy = sum(m['healthy'] for m in source['members']); quorum = len(source['members'])//2+1
        if part == 1: return e['healthyMembers'] == healthy and e['quorum'] == quorum and e['snapshotUsable'] is True == source['snapshot']['encrypted'] == source['snapshot']['verified']
        return e['restoreAllowedNow'] is False and e['firstAction'] == 'investigate-member' and e['snapshotPath'] == source['snapshot']['path'] and source['changeWindowApproved'] is False
    if id == 'A14':
        e = evidence(id)
        endpoint = urlparse(live('config','view','--minify')['clusters'][0]['cluster']['server']).hostname
        config = live('config','view','--raw','--minify')['clusters'][0]['cluster']
        uri = urlparse(config['server']); port = uri.port or 443
        ctx = ssl.create_default_context()
        if config.get('certificate-authority-data'):
            ca = base64.b64decode(config['certificate-authority-data'])
            ctx.load_verify_locations(cadata=ca.decode() if ca.startswith(b'-----BEGIN') else ca)
        elif config.get('certificate-authority'):
            ctx.load_verify_locations(cafile=config['certificate-authority'])
        with socket.create_connection((endpoint,port), timeout=3) as sock:
            with ctx.wrap_socket(sock, server_hostname=endpoint) as tls:
                cert = tls.getpeercert()
        issuer = ','.join('='.join(item) for rdn in cert['issuer'] for item in rdn)
        expires = dt.datetime.fromtimestamp(ssl.cert_time_to_seconds(cert['notAfter']), dt.timezone.utc)
        if part == 1: return e['host'] == endpoint and e['issuer'] == issuer
        observed = dt.datetime.fromisoformat(e['notAfter'].replace('Z','+00:00'))
        return (observed == expires and expires > dt.datetime.now(dt.timezone.utc)
                and abs(e['daysRemaining'] - (expires-dt.datetime.now(dt.timezone.utc)).days) <= 1)
    if id == 'A15':
        e = evidence(id)
        if part == 1:
            return (e['validatingWebhookCount'] == len(live('get','validatingwebhookconfigurations')['items'])
                    and e['mutatingWebhookCount'] == len(live('get','mutatingwebhookconfigurations')['items']))
        return e['podSecurityEnforce'] == live('get','namespace',ns)['metadata'].get('labels',{}).get('pod-security.kubernetes.io/enforce','unset')
    if id == 'A16':
        docs = documents(state / 'A16-operator.yaml')
        kinds = {d['kind']:d for d in docs}
        if len(docs)!=6 or set(kinds)!={'CustomResourceDefinition','Signal','Deployment','ServiceAccount','Role','RoleBinding'}:return False
        crd = kinds['CustomResourceDefinition']['spec']; sample = documents(root / 'samples/architecture/crd.yaml')[0]['spec']
        if part == 1:
            return (kinds['CustomResourceDefinition'].get('apiVersion')=='apiextensions.k8s.io/v1'
                    and crd['group'] == sample['group'] and crd['names']['kind'] == 'Signal'
                    and crd['scope'] == 'Namespaced' and crd['names']['plural']=='signals'
                    and sum(bool(v.get('storage')) for v in crd['versions'])==1
                    and any(v['storage'] and v['served'] and v.get('schema',{}).get('openAPIV3Schema') for v in crd['versions'])
                    and kinds['CustomResourceDefinition']['metadata']['name'] == 'signals.telemetry.example.test'
                    and kinds['CustomResourceDefinition']['metadata'].get('labels',{}).get('cka-lab.io/owner') == owner
                    and kinds['CustomResourceDefinition']['metadata']['labels'].get('cka-lab.io/prefix') == prefix
                    and valid_scope(kinds['Signal']) and kinds['Signal']['metadata']['name'] == 'harbor-signal'
                    and kinds['Signal']['apiVersion'] in [f"{crd['group']}/{v['name']}" for v in crd['versions'] if v['served']])
        role=kinds['Role']; binding=kinds['RoleBinding']; sa=kinds['ServiceAccount']; deploy=kinds['Deployment']
        return (all(valid_scope(kinds[k]) for k in ('Signal','Deployment','ServiceAccount','Role','RoleBinding'))
                and all(kinds[k]['metadata']['name']=='signal-operator' for k in ('Deployment','ServiceAccount','Role','RoleBinding'))
                and deploy['spec']['template']['spec']['serviceAccountName']=='signal-operator'
                and deploy.get('apiVersion')=='apps/v1'
                and deploy['spec']['replicas']==1
                and deploy['spec']['selector']['matchLabels'].items() <= deploy['spec']['template']['metadata']['labels'].items()
                and deploy['spec']['template']['metadata']['labels'].get('cka-lab.io/owner')==owner
                and len(deploy['spec']['template']['spec']['containers'])==1
                and deploy['spec']['template']['spec']['containers'][0]['image']=='busybox:1.36'
                and all(set(r['verbs'])=={'get','list','watch'} and r['apiGroups']==[crd['group']] and r['resources']==['signals'] for r in role['rules'])
                and bool(role['rules']) and role.get('apiVersion')=='rbac.authorization.k8s.io/v1'
                and binding.get('apiVersion')=='rbac.authorization.k8s.io/v1'
                and sa.get('apiVersion')=='v1'
                and binding['roleRef'].get('apiGroup')=='rbac.authorization.k8s.io'
                and binding['roleRef']['kind']=='Role' and binding['roleRef']['name']=='signal-operator'
                and binding['subjects']==[{'kind':'ServiceAccount','name':'signal-operator','namespace':ns}])
    if id == 'A17':
        source=json.loads((root/'samples/architecture/ha.json').read_text());e=evidence(id)
        healthy=sum(m['healthy'] for m in source['members']); quorum=len(source['members'])//2+1
        if part==1:return e['members']==len(source['members']) and e['healthyMembers']==healthy and e['quorum']==quorum and e['survivesAnotherFailure'] == (healthy-1>=quorum)
        return (e['apiEndpoint']==source['apiEndpoint']
                and e['endpointInSANs']==(source['apiEndpoint'].split(':')[0] in source['certificateSANs'])
                and e['replacementZone']==source['candidateZone']
                and e['membershipMutationAllowedNow'] is False and e['nextStep']=='restore-elm-health')
    if id == 'A18':
        docs=documents(state/'A18-component.yaml')
        if len(docs)!=1:return False
        if part==1:return deployment(docs[0],'collector-agent',2,'nginx:1.27-alpine')
        import yaml
        rendered=list(yaml.safe_load_all(command('kubectl','kustomize',str(state/'A18-overlay'))))
        return len(rendered)==1 and rendered[0]['spec']==docs[0]['spec'] and rendered[0]['metadata']==docs[0]['metadata']
    return False

try:
    ok = check(sys.argv[1],int(sys.argv[2]))
except (Exception,) as error:
    if os.environ.get('CKA_ARCH_DEBUG'): print(type(error).__name__,str(error),file=sys.stderr)
    ok = False
sys.exit(0 if ok else 1)
