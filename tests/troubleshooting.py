#!/usr/bin/env python3
"""Offline positive and near-miss checks of troubleshooting score predicates."""
import copy
import importlib.util
import json
import os
from pathlib import Path
import tempfile

root = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('check_troubleshooting', root / 'scripts/check_troubleshooting.py')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
mod.NAMESPACE = 'cove-zone'  # override, not the default namespace


def check(task, part, accept):
    try:
        mod.check(task, part)
        result = True
    except (AssertionError, KeyError, ValueError, IndexError, TypeError):
        result = False
    assert result == accept, (task, part, accept)


owner = {'cka-lab.io/owner': 'cka-talos-practice'}
objects = {}
def obj(kind, name, spec, status=None):
    objects[(kind, name)] = {'metadata': {'name': name, 'namespace': mod.NAMESPACE, 'labels': owner,
                                        'generation': 2}, 'spec': spec, 'status': status or {}}

def get(kind, name, namespace=mod.NAMESPACE):
    return copy.deepcopy(objects[(kind, name)])

mod.get = get

def run(*args):
    if args[:3] == ('kubectl', 'top', 'nodes'):
        return 'NAME CPU(cores) CPU% MEMORY(bytes) MEMORY%\nnode-1 12m 1% 20Mi 1%'
    if args[:3] == ('kubectl', 'top', 'pods'):
        return 'NAME CPU(cores) MEMORY(bytes)\nweb-abc 5m 16Mi'
    if args[0:3] == ('kubectl', 'get', 'endpointslices'):
        return json.dumps({'items': [{'endpoints': [{'conditions': {'ready': True}, 'addresses': ['10.0.0.2']}]}]})
    if args[:2] == ('kubectl', 'exec'):
        return 'Name: web.cove-zone.svc.cluster.local\nAddress: 10.0.0.2'
    if args[:2] == ('kubectl', 'logs'):
        return 'Iface Destination Gateway\nName:\tsh'
    if args[:4] == ('kubectl', 'get', '--raw', '/readyz'):
        return 'ok'
    if args[:3] == ('kubectl', 'get', 'pods'):
        component = args[args.index('-l') + 1].split('=')[1]
        return json.dumps({'items': [{'metadata': {'name': component + '-node-1'},
                                      'spec': {'nodeName': 'node-1'},
                                      'status': {'phase': 'Running', 'containerStatuses': [{'ready': True}]}}]})
    if args[0] == 'talosctl':
        return '{"metadata":{}}' if 'members' in args else 'STATE Running'
    raise AssertionError(args)
mod.run = run

with tempfile.TemporaryDirectory() as tmp:
    mod.EVIDENCE = Path(tmp)
    status = {'observedGeneration': 2, 'updatedReplicas': 1, 'availableReplicas': 1}
    obj('deployment', 'sable-view', {'replicas': 1, 'selector': {'matchLabels': {'app': 'sable-view'}}, 'template': {'spec': {'containers': [{'name': 'web', 'image': 'nginx:1.27-alpine'}]}}}, status)
    check('T01', 1, True); check('T01', 2, True)
    objects['deployment', 'sable-view']['spec']['template']['spec']['containers'][0]['image'] = 'nginx:unrelated'
    check('T01', 1, False); check('T01', 2, False)
    obj('deployment', 'sable-probe', {'replicas': 1, 'selector': {'matchLabels': {'app': 'sable-probe'}}, 'template': {'spec': {'containers': [{'name': 'web', 'image': 'nginx:1.27-alpine', 'readinessProbe': {'httpGet': {'path': '/', 'port': 80}}}]}}}, status)
    check('T02', 1, True); check('T02', 2, True)
    objects['deployment', 'sable-probe']['spec']['template']['spec']['containers'][0]['readinessProbe']['httpGet']['port'] = 81
    check('T02', 1, False); check('T02', 2, False)
    obj('pod', 'sable-worker', {'containers': [{'name': 'sleeper', 'image': 'busybox:1.36', 'command': ['sh', '-c', 'sleep 7d'], 'resources': {'requests': {'cpu': '5m', 'memory': '8Mi'}}}]}, {'phase': 'Running', 'containerStatuses': [{'ready': True}]})
    check('T03', 1, True); check('T03', 2, True)
    objects['pod', 'sable-worker']['spec']['nodeSelector'] = {'cka-lab.io/nonexistent': 'true'}
    check('T03', 1, False); check('T03', 2, False)
    obj('service', 'sable-route', {'selector': {'app': 'web'}, 'ports': [{'port': 80, 'targetPort': 80}]})
    check('T04', 1, True); check('T04', 2, True)
    objects['service', 'sable-route']['spec']['ports'][0]['targetPort'] = 81
    check('T04', 1, False); check('T04', 2, False)
    obj('pod', 'dns-stray', {'dnsPolicy': 'ClusterFirst', 'containers': [{'name': 'resolver', 'image': 'busybox:1.36', 'command': ['sh', '-c', 'sleep 7d'], 'resources': {'requests': {'cpu': '5m', 'memory': '8Mi'}}}]}, {'phase': 'Running'})
    check('T05', 1, True); check('T05', 2, True)
    objects['pod', 'dns-stray']['spec']['dnsConfig'] = {'nameservers': ['192.0.2.53']}
    check('T05', 1, False); check('T05', 2, False)
    obj('deployment', 'log-churn', {'replicas': 1, 'selector': {'matchLabels': {'app': 'log-churn'}}, 'template': {'spec': {'containers': [{'name': 'worker', 'image': 'busybox:1.36', 'command': ['sh', '-c', 'sleep 7d']}]}}}, status)
    (mod.EVIDENCE / 'T06.json').write_text(json.dumps({'previousMarker': 'ledger-worker: startup rejected (exit 17)', 'container': 'worker', 'deployment': 'log-churn'}))
    check('T06', 1, True); check('T06', 2, True)
    objects['deployment', 'log-churn']['spec']['template']['spec']['containers'][0]['command'] = ['sh', '-c', 'true']
    check('T06', 2, False)
    import yaml
    sample = (root / 'samples/troubleshooting/qos.yaml').read_text()
    pods = list(yaml.safe_load_all(sample))
    pods[0]['spec']['containers'][0]['resources'] = {'requests': {'cpu': '50m', 'memory': '32Mi'}, 'limits': {'cpu': '50m', 'memory': '32Mi'}}
    (mod.EVIDENCE / 'T07-pods.yaml').write_text(yaml.safe_dump_all(pods))
    (mod.EVIDENCE / 'T07.json').write_text(json.dumps({'first': 'probe-scratch', 'second': 'edge-cache', 'last': 'archive-index', 'pressure': 'memory', 'equalPriority': True}))
    check('T07', 1, True); check('T07', 2, True)
    pods[1]['metadata']['name'] = 'not-edge-cache'
    (mod.EVIDENCE / 'T07-pods.yaml').write_text(yaml.safe_dump_all(pods))
    check('T07', 1, False); check('T07', 2, True)
    (mod.EVIDENCE / 'T07.json').write_text(json.dumps({'first': 'archive-index', 'second': 'edge-cache', 'last': 'probe-scratch', 'pressure': 'memory', 'equalPriority': True}))
    check('T07', 2, False)
    (mod.EVIDENCE / 'T08.json').write_text(json.dumps({'node': 'node-1', 'namespace': mod.NAMESPACE, 'pod': 'web-abc'}))
    (mod.EVIDENCE / 'T08.sh').write_text('kubectl top nodes\nkubectl top pods -n "$CKA_LAB_NAMESPACE"\n')
    check('T08', 1, True); check('T08', 2, True)
    (mod.EVIDENCE / 'T08.json').write_text(json.dumps({'node': 'node-1', 'namespace': 'wrong', 'pod': 'web-abc'}))
    check('T08', 2, False)
    node_status = {'conditions': [{'type': k, 'status': v} for k, v in [('Ready', 'True'), ('MemoryPressure', 'False'), ('DiskPressure', 'False'), ('PIDPressure', 'False')]], 'capacity': {'cpu': '4', 'memory': '8Gi'}, 'allocatable': {'cpu': '3800m', 'memory': '7Gi'}, 'nodeInfo': {'containerRuntimeVersion': 'containerd://2.0'}}
    objects['node', 'node-1'] = {'metadata': {'labels': {'node-role.kubernetes.io/control-plane': ''}}, 'spec': {}, 'status': node_status}
    (mod.EVIDENCE / 'T09.json').write_text(json.dumps({'node': 'node-1', 'conditions': {'Ready': 'True', 'MemoryPressure': 'False', 'DiskPressure': 'False', 'PIDPressure': 'False'}, 'taints': [], 'capacity': {'cpu': '4', 'memory': '8Gi'}, 'allocatable': {'cpu': '3800m', 'memory': '7Gi'}}))
    check('T09', 1, True); check('T09', 2, True)
    objects['node', 'node-1']['status']['allocatable']['cpu'] = '3700m'
    check('T09', 2, False)
    obj('pod', 'toolbox', {'nodeName': 'node-1', 'containers': [{'name': 'toolbox'}], 'ephemeralContainers': [{'name': 'inspect-1', 'targetContainerName': 'toolbox', 'image': 'busybox:1.36', 'command': ['sh', '-c', 'cat /proc/net/route; cat /proc/1/status']}]}, {'ephemeralContainerStatuses': [{'name': 'inspect-1', 'state': {'terminated': {'exitCode': 0}}}]})
    (mod.EVIDENCE / 'T10.json').write_text(json.dumps({'node': 'node-1', 'runtimeVersion': 'containerd://2.0', 'podRuntimeClass': '', 'kubeletService': 'Running', 'containerdService': 'Running'}))
    check('T10', 1, True); check('T10', 2, True)
    objects['pod', 'toolbox']['spec']['nodeName'] = 'node-2'
    check('T10', 1, False); check('T10', 2, False)
    objects['pod', 'toolbox']['spec']['nodeName'] = 'node-1'
    (mod.EVIDENCE / 'T11.json').write_text(json.dumps({'controlPlaneNode': 'node-1', 'apiReady': True, 'componentPods': {c: c + '-node-1' for c in ('kube-apiserver', 'kube-scheduler', 'kube-controller-manager')}, 'services': {'etcd': 'Running'}, 'memberCount': 1}))
    check('T11', 1, True); check('T11', 2, True)
    objects['node', 'node-1']['metadata']['labels'] = {}
    check('T11', 1, False); check('T11', 2, False)
    objects['node', 'node-1']['metadata']['labels'] = {'node-role.kubernetes.io/control-plane': ''}
    check('T12', 1, True); check('T12', 2, True)
    objects['pod', 'toolbox']['spec']['ephemeralContainers'][0]['image'] = 'busybox:wrong'
    check('T12', 1, False); check('T12', 2, False)
print('ok: troubleshooting 12-task positive/near-miss predicates and namespace override')
