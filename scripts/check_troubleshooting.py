#!/usr/bin/env python3
"""Read-only, task-specific checks for the troubleshooting pillar."""
import json
import os
from pathlib import Path
import re
import subprocess
import sys

NAMESPACE = os.environ.get('NAMESPACE', 'cka-practice')
EVIDENCE = Path(os.environ.get('CKA_LAB_STATE_DIR', '.lab')) / 'evidence'
OWNER = 'cka-talos-practice'


def run(*args):
    return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL, timeout=12).strip()


def get(kind, name, namespace=NAMESPACE):
    args = ['kubectl', 'get', kind, name]
    if namespace:
        args += ['-n', namespace]
    return json.loads(run(*args, '-o', 'json'))


def evidence(task, suffix='json'):
    return json.loads((EVIDENCE / f'{task}.{suffix}').read_text())


def owned(obj):
    return obj.get('metadata', {}).get('labels', {}).get('cka-lab.io/owner') == OWNER and obj['metadata'].get('namespace') == NAMESPACE


def deployed(name):
    d = get('deployment', name)
    assert owned(d) and d['spec'].get('replicas') == 1
    status = d.get('status', {})
    assert status.get('observedGeneration', 0) >= d['metadata']['generation']
    assert status.get('updatedReplicas') == status.get('availableReplicas') == 1
    return d


def check(task, part):
    if task == 'T01':
        d = deployed('sable-view') if part == 2 else get('deployment', 'sable-view')
        assert owned(d)
        c = d['spec']['template']['spec']['containers'][0]
        assert c['name'] == 'web' and c['image'] == 'nginx:1.27-alpine'
        assert d['spec']['selector']['matchLabels'] == {'app': 'sable-view'}
    elif task == 'T02':
        d = deployed('sable-probe') if part == 2 else get('deployment', 'sable-probe')
        assert owned(d)
        c = d['spec']['template']['spec']['containers'][0]
        assert c['name'] == 'web' and c['image'] == 'nginx:1.27-alpine'
        assert c['readinessProbe']['httpGet'] == {'path': '/', 'port': 80}
        assert d['spec']['selector']['matchLabels'] == {'app': 'sable-probe'}
    elif task == 'T03':
        p = get('pod', 'sable-worker')
        assert owned(p) and p['spec'].get('nodeSelector', {}) == {}
        assert len(p['spec']['containers']) == 1
        c = p['spec']['containers'][0]
        assert all(c.get(k) == v for k, v in {'name': 'sleeper', 'image': 'busybox:1.36',
                    'command': ['sh', '-c', 'sleep 7d'],
                    'resources': {'requests': {'cpu': '5m', 'memory': '8Mi'}}}.items())
        if part == 2:
            assert p['status']['phase'] == 'Running' and p['status']['containerStatuses'][0]['ready'] is True
    elif task == 'T04':
        s = get('service', 'sable-route')
        assert owned(s) and s['spec']['selector'] == {'app': 'web'}
        assert s['spec']['ports'][0]['port'] == s['spec']['ports'][0]['targetPort'] == 80
        if part == 2:
            slices = json.loads(run('kubectl', 'get', 'endpointslices', '-n', NAMESPACE,
                                    '-l', 'kubernetes.io/service-name=sable-route', '-o', 'json'))['items']
            assert any(x.get('conditions', {}).get('ready') is True and x.get('addresses')
                       for sl in slices for x in sl.get('endpoints', []))
    elif task == 'T05':
        p = get('pod', 'dns-stray')
        assert owned(p) and p['spec']['dnsPolicy'] == 'ClusterFirst' and not p['spec'].get('dnsConfig')
        assert len(p['spec']['containers']) == 1
        c = p['spec']['containers'][0]
        assert all(c.get(k) == v for k, v in {'name': 'resolver', 'image': 'busybox:1.36',
                    'command': ['sh', '-c', 'sleep 7d'],
                    'resources': {'requests': {'cpu': '5m', 'memory': '8Mi'}}}.items())
        if part == 2:
            assert p['status']['phase'] == 'Running'
            result = run('kubectl', 'exec', '-n', NAMESPACE, 'dns-stray', '--',
                         'nslookup', f'web.{NAMESPACE}.svc.cluster.local')
            assert 'Name:' in result and re.search(r'Address(?:es)?:\s*\d', result)
    elif task == 'T06':
        d = get('deployment', 'log-churn')
        assert owned(d)
        if part == 1:
            e = evidence(task)
            assert e == {'previousMarker': 'ledger-worker: startup rejected (exit 17)',
                         'container': 'worker', 'deployment': 'log-churn'}
        else:
            d = deployed('log-churn')
            c = d['spec']['template']['spec']['containers'][0]
            assert c['name'] == 'worker' and c['image'] == 'busybox:1.36'
            assert d['spec']['selector']['matchLabels'] == {'app': 'log-churn'}
            assert c['command'] == ['sh', '-c', 'sleep 7d']
    elif task == 'T07':
        if part == 1:
            import yaml
            original = list(yaml.safe_load_all((Path(os.environ.get('CKA_TASK_RESOURCES', Path(__file__).resolve().parent.parent / 'samples/troubleshooting')) / 'qos.yaml').read_text()))
            altered = list(yaml.safe_load_all((EVIDENCE / 'T07-pods.yaml').read_text()))
            assert len(altered) == len(original) == 3
            by_name = {o['metadata']['name']: o for o in altered}
            assert set(by_name) == {o['metadata']['name'] for o in original}
            for o in original:
                name = o['metadata']['name']
                target = by_name[name]
                if name == 'archive-index':
                    expected = json.loads(json.dumps(o))
                    expected['spec']['containers'][0]['resources'] = {'requests': {'cpu': '50m', 'memory': '32Mi'},
                                                                        'limits': {'cpu': '50m', 'memory': '32Mi'}}
                    assert target == expected
                else:
                    assert target == o
        else:
            assert evidence(task) == {'first': 'probe-scratch', 'second': 'edge-cache',
                                      'last': 'archive-index', 'pressure': 'memory',
                                      'equalPriority': True}
    elif task == 'T08':
        e = evidence(task)
        node_top = run('kubectl', 'top', 'nodes')
        pod_top = run('kubectl', 'top', 'pods', '-n', NAMESPACE)
        if part == 1:
            assert any(
                line.split()[0] == e['node'] and re.fullmatch(r'\d+m', line.split()[1])
                and re.fullmatch(r'\d+Mi', line.split()[3]) for line in node_top.splitlines()[1:])
        else:
            script = (EVIDENCE / 'T08.sh').read_text()
            lines = [line.strip() for line in script.splitlines() if line.strip() and not line.startswith('#!')]
            assert lines == ['kubectl top nodes', f'kubectl top pods -n {NAMESPACE}'] or lines == [
                'kubectl top nodes', 'kubectl top pods -n "$CKA_LAB_NAMESPACE"']
            assert e['namespace'] == NAMESPACE and e['pod'].startswith('web-')
            assert any(line.split()[0] == e['pod'] and re.fullmatch(r'\d+m', line.split()[1])
                       and re.fullmatch(r'\d+Mi', line.split()[2]) for line in pod_top.splitlines()[1:])
    elif task == 'T09':
        e = evidence(task)
        n = get('node', e['node'], None)
        if part == 1:
            actual = {c['type']: c['status'] for c in n['status']['conditions']}
            assert e['conditions'] == {k: actual[k] for k in ('Ready', 'MemoryPressure', 'DiskPressure', 'PIDPressure')}
            assert e['taints'] == n['spec'].get('taints', [])
        else:
            assert e['capacity'] == {k: n['status']['capacity'][k] for k in ('cpu', 'memory')}
            assert e['allocatable'] == {k: n['status']['allocatable'][k] for k in ('cpu', 'memory')}
    elif task == 'T10':
        e = evidence(task)
        n = get('node', e['node'], None)
        assert e['runtimeVersion'] == n['status']['nodeInfo']['containerRuntimeVersion']
        p = get('pod', 'toolbox')
        assert owned(p) and p['spec']['nodeName'] == e['node']
        if part == 1:
            assert e['podRuntimeClass'] == p['spec'].get('runtimeClassName', '')
            assert e['runtimeVersion'].startswith('containerd://')
        else:
            # Services are observed with Talos API only; do not SSH into nodes.
            assert e['kubeletService'] == 'Running' and e['containerdService'] == 'Running'
            for name in ('kubelet', 'containerd'):
                output = run('talosctl', '-n', e['node'], 'service', name)
                assert re.search(r'(?im)^\s*state\s+Running\s*$', output)
    elif task == 'T11':
        e = evidence(task)
        n = get('node', e['controlPlaneNode'], None)
        assert 'node-role.kubernetes.io/control-plane' in n['metadata'].get('labels', {})
        if part == 1:
            assert e['apiReady'] is True and run('kubectl', 'get', '--raw', '/readyz') == 'ok'
            for component in ('kube-apiserver', 'kube-scheduler', 'kube-controller-manager'):
                pods = json.loads(run('kubectl', 'get', 'pods', '-n', 'kube-system',
                                      '-l', f'component={component}', '-o', 'json'))['items']
                assert any(p['metadata']['name'] == e['componentPods'][component]
                           and p['spec']['nodeName'] == e['controlPlaneNode']
                           and p['status']['phase'] == 'Running'
                           and all(c['ready'] for c in p['status']['containerStatuses']) for p in pods)
        else:
            assert e['services']['etcd'] == 'Running'
            assert re.search(r'(?im)^\s*state\s+Running\s*$',
                             run('talosctl', '-n', e['controlPlaneNode'], 'service', 'etcd'))
            assert e['memberCount'] >= 1
            members = run('talosctl', '-n', e['controlPlaneNode'], 'get', 'members', '-o', 'json')
            assert len([line for line in members.splitlines() if line.strip().startswith('{')]) == e['memberCount']
    elif task == 'T12':
        p = get('pod', 'toolbox')
        assert owned(p)
        containers = p['spec'].get('ephemeralContainers', [])
        assert len(containers) == 1
        c = containers[0]
        assert c.get('targetContainerName') == 'toolbox' and c.get('image') == 'busybox:1.36'
        assert c.get('name', '').startswith('inspect-') and c.get('command') == ['sh', '-c', 'cat /proc/net/route; cat /proc/1/status']
        if part == 2:
            statuses = p['status'].get('ephemeralContainerStatuses', [])
            assert any(s['name'] == c['name'] and s.get('state', {}).get('terminated', {}).get('exitCode') == 0
                       for s in statuses)
            output = run('kubectl', 'logs', '-n', NAMESPACE, 'toolbox', '-c', c['name'])
            assert 'Iface' in output and 'Destination' in output and 'Name:' in output
    else:
        raise ValueError(task)


if __name__ == '__main__':
    try:
        check(sys.argv[1], int(sys.argv[2]))
    except (AssertionError, KeyError, ValueError, OSError, subprocess.SubprocessError, IndexError, TypeError):
        sys.exit(1)
