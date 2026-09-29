#!/usr/bin/env python3
"""Read-only, exact workload end-state checks. Each task has two independent criteria."""
import json
import os
from pathlib import Path
import subprocess
import sys

import yaml

TASK, PART = sys.argv[1], int(sys.argv[2])
NS = os.environ.get('CKA_LAB_NAMESPACE', os.environ.get('CKA_LAB_PREFIX', 'cka-practice'))
ROOT = Path(__file__).resolve().parent.parent
OWNER = 'cka-talos-practice'


def get(kind, name):
    try:
        return json.loads(subprocess.check_output(
            ['kubectl', 'get', kind, name, '-n', NS, '-o', 'json'], stderr=subprocess.DEVNULL))
    except (subprocess.CalledProcessError, ValueError):
        return {}


def owned(obj):
    meta = obj.get('metadata', {})
    return meta.get('namespace') == NS and meta.get('labels', {}).get('cka-lab.io/owner') == OWNER


def spec(kind, name):
    obj = get(kind, name)
    return obj.get('spec', {}) if owned(obj) else {}


def container(s):
    return (s.get('template', s).get('spec', {}).get('containers') or [{}])[0]


def ready(kind, name, replicas):
    obj = get(kind, name)
    return owned(obj) and obj.get('status', {}).get('observedGeneration', 0) >= obj.get('metadata', {}).get('generation', 1) and obj.get('status', {}).get('readyReplicas') == replicas


def running(name):
    obj = get('pod', name)
    return owned(obj) and obj.get('status', {}).get('phase') == 'Running' and any(
        c.get('type') == 'Ready' and c.get('status') == 'True' for c in obj.get('status', {}).get('conditions', []))


def labels(s, name):
    return s.get('selector', {}).get('matchLabels') == {'app': name} and s.get('template', {}).get('metadata', {}).get('labels', {}).get('app') == name


def node_names():
    try:
        data = json.loads(subprocess.check_output(['kubectl', 'get', 'nodes', '-l', 'node-role.kubernetes.io/worker', '-o', 'json'], stderr=subprocess.DEVNULL))
    except (subprocess.CalledProcessError, ValueError):
        return []
    return [n['metadata']['name'] for n in data.get('items', []) if not n.get('spec', {}).get('unschedulable')
            and not any(t.get('effect') in ('NoSchedule', 'NoExecute') for t in n.get('spec', {}).get('taints', []))
            and any(c.get('type') == 'Ready' and c.get('status') == 'True' for c in n.get('status', {}).get('conditions', []))]


def pod_nodes(label):
    try:
        data = json.loads(subprocess.check_output(['kubectl', 'get', 'pods', '-n', NS, '-l', f'app={label}', '-o', 'json'], stderr=subprocess.DEVNULL))
    except (subprocess.CalledProcessError, ValueError):
        return []
    return [p.get('spec', {}).get('nodeName') for p in data.get('items', [])
            if p.get('status', {}).get('phase') == 'Running'
            and p.get('metadata', {}).get('labels', {}).get('cka-lab.io/owner') == OWNER]


def offline_pod():
    try:
        return yaml.safe_load((Path(os.environ.get('CKA_LAB_STATE_DIR', ROOT / '.lab')) / 'evidence/W09-pod.yaml').read_text())
    except (OSError, yaml.YAMLError):
        return {}

if TASK == 'workers':
    data = json.load(sys.stdin)
    count = sum(not n.get('spec', {}).get('unschedulable')
              and not any(t.get('effect') in ('NoSchedule', 'NoExecute') for t in n.get('spec', {}).get('taints', []))
              and any(c.get('type') == 'Ready' and c.get('status') == 'True' for c in n.get('status', {}).get('conditions', []))
              for n in data.get('items', []))
    print(count)
    sys.exit(0)

s = {}
good = False
if TASK == 'W01':
    s = spec('deployment', 'ember-api')
    c = container(s)
    good = (s.get('replicas') == 2 and labels(s, 'ember-api') and c.get('image') == 'nginx:1.27-alpine'
            and c.get('resources', {}).get('requests') == {'cpu': '20m', 'memory': '32Mi'}
            and c.get('resources', {}).get('limits') == {'cpu': '100m', 'memory': '64Mi'}) if PART == 1 else ready('deployment', 'ember-api', 2)
elif TASK in ('W02', 'W03'):
    name, image = ('ember-release', 'nginx:1.27-alpine') if TASK == 'W02' else ('ember-recovery', 'nginx:1.27-alpine')
    s = spec('deployment', name)
    if PART == 1:
        good = labels(s, name) and s.get('replicas') == (2 if TASK == 'W02' else 1) and container(s).get('image') == image
        if TASK == 'W02':
            good = good and s.get('strategy') == {'type': 'RollingUpdate', 'rollingUpdate': {'maxSurge': 1, 'maxUnavailable': 0}}
    else:
        good = ready('deployment', name, 2 if TASK == 'W02' else 1)
        if TASK == 'W03':
            try:
                history = subprocess.check_output(['kubectl', 'rollout', 'history', 'deployment/' + name, '-n', NS], stderr=subprocess.DEVNULL).decode()
                good = good and len([line for line in history.splitlines() if line.strip().split(' ')[0].isdigit()]) >= 2
            except subprocess.CalledProcessError:
                good = False
elif TASK == 'W04':
    if PART == 1:
        obj = get('job', 'ember-batch'); s = spec('job', 'ember-batch')
        good = (owned(obj) and s.get('completions') == 1 and s.get('parallelism') == 1
                and s.get('template', {}).get('spec', {}).get('restartPolicy') == 'Never'
                and container(s).get('image') == 'busybox:1.36'
                and container(s).get('command') == ['sh', '-c', 'echo report-ready']
                and s.get('template', {}).get('metadata', {}).get('labels', {}).get('cka-lab.io/owner') == OWNER
                and any(c.get('type') == 'Complete' and c.get('status') == 'True' for c in obj.get('status', {}).get('conditions', [])))
    else:
        s = spec('cronjob', 'ember-timer'); template = s.get('jobTemplate', {}).get('spec', {}).get('template', {}).get('spec', {})
        good = (s.get('schedule') == '*/10 * * * *' and s.get('suspend') is True
                and s.get('successfulJobsHistoryLimit') == 1 and s.get('failedJobsHistoryLimit') == 1
                and template.get('restartPolicy') == 'Never' and (template.get('containers') or [{}])[0].get('image') == 'busybox:1.36'
                and (template.get('containers') or [{}])[0].get('command') == ['sh', '-c', 'echo timer-ready']
                and s.get('jobTemplate', {}).get('spec', {}).get('template', {}).get('metadata', {}).get('labels', {}).get('cka-lab.io/owner') == OWNER)
elif TASK == 'W05':
    s = spec('daemonset', 'ember-observer'); obj = get('daemonset', 'ember-observer')
    if PART == 1:
        good = (labels(s, 'ember-observer') and s.get('template', {}).get('spec', {}).get('nodeSelector') == {'node-role.kubernetes.io/worker': ''}
                and container(s).get('image') == 'busybox:1.36'
                and container(s).get('command') == ['sh', '-c', 'sleep 7d']
                and s.get('template', {}).get('metadata', {}).get('labels', {}).get('cka-lab.io/owner') == OWNER
                and not s.get('template', {}).get('spec', {}).get('tolerations')
                and container(s).get('resources', {}).get('requests') == {'cpu': '5m', 'memory': '8Mi'})
    else:
        nodes = node_names(); status = obj.get('status', {})
        good = (owned(obj) and bool(nodes) and status.get('desiredNumberScheduled') == len(nodes)
                and status.get('numberReady') == len(nodes) and set(pod_nodes('ember-observer')) == set(nodes))
elif TASK == 'W06':
    s = spec('statefulset', 'ember-ledger'); svc = spec('service', 'ember-ledger')
    if PART == 1:
        good = s.get('replicas') == 2 and s.get('serviceName') == 'ember-ledger' and labels(s, 'ember-ledger') and svc.get('clusterIP') == 'None' and svc.get('selector') == {'app': 'ember-ledger'} and not s.get('volumeClaimTemplates')
    else:
        nodes = {p.get('metadata', {}).get('name') for p in json.loads(subprocess.check_output(['kubectl', 'get', 'pods', '-n', NS, '-l', 'app=ember-ledger', '-o', 'json'], stderr=subprocess.DEVNULL)).get('items', []) if p.get('status', {}).get('phase') == 'Running' and p.get('metadata', {}).get('labels', {}).get('cka-lab.io/owner') == OWNER}
        good = ready('statefulset', 'ember-ledger', 2) and nodes == {'ember-ledger-0', 'ember-ledger-1'}
elif TASK == 'W07':
    cm, secret, pod = get('configmap', 'ember-settings'), get('secret', 'ember-token'), get('pod', 'ember-consumer')
    if PART == 1:
        good = owned(cm) and cm.get('data', {}).get('MODE') == 'audit' and owned(secret) and secret.get('data', {}).get('TOKEN') == 'ZHVtbXk=' and secret.get('type') == 'Opaque'
    else:
        env = (pod.get('spec', {}).get('containers') or [{}])[0].get('env', [])
        good = owned(pod) and running('ember-consumer') and (pod.get('spec', {}).get('containers') or [{}])[0].get('image') == 'busybox:1.36' and (pod.get('spec', {}).get('containers') or [{}])[0].get('command') == ['sh', '-c', 'sleep 7d'] and all(any(e.get('name') == key and e.get('valueFrom', {}).get(ref, {}).get('name') == name and e['valueFrom'][ref].get('key') == source for e in env) for key, ref, name, source in [('MODE', 'configMapKeyRef', 'ember-settings', 'MODE'), ('TOKEN', 'secretKeyRef', 'ember-token', 'TOKEN')])
elif TASK == 'W08':
    s = spec('deployment', 'ember-placement'); affinity = s.get('template', {}).get('spec', {}).get('affinity', {})
    node = affinity.get('nodeAffinity', {}).get('requiredDuringSchedulingIgnoredDuringExecution', {}).get('nodeSelectorTerms', [])
    anti = affinity.get('podAntiAffinity', {}).get('requiredDuringSchedulingIgnoredDuringExecution', [])
    if PART == 1:
        good = (s.get('replicas') == 2 and labels(s, 'ember-placement')
                and node == [{'matchExpressions': [{'key': 'node-role.kubernetes.io/worker', 'operator': 'Exists'}]}]
                and anti == [{'labelSelector': {'matchLabels': {'app': 'ember-placement'}}, 'topologyKey': 'kubernetes.io/hostname'}])
    else:
        nodes = pod_nodes('ember-placement')
        good = ready('deployment', 'ember-placement', 2) and len(nodes) == 2 and len(set(nodes)) == 2 and set(nodes) <= set(node_names())
elif TASK == 'W09':
    pod = offline_pod() or {}; ps = pod.get('spec', {}); taints = ps.get('tolerations', [])
    if PART == 1:
        good = (pod.get('kind') == 'Pod' and pod.get('metadata', {}).get('name') == 'ember-isolate'
                and ps.get('nodeSelector') == {'kubernetes.io/hostname': 'oak-a'}
                and ps.get('containers', [{}])[0].get('image') == 'busybox:1.36')
    else:
        good = taints == [{'key': 'training.example.test/isolated', 'operator': 'Equal', 'value': 'yes', 'effect': 'NoSchedule'}] and ps.get('containers', [{}])[0].get('resources', {}).get('requests') == {'cpu': '5m', 'memory': '8Mi'}
elif TASK == 'W10':
    s = spec('hpa', 'ember-autoscale'); metric = [{'type': 'Resource', 'resource': {'name': 'cpu', 'target': {'type': 'Utilization', 'averageUtilization': 60}}}]
    if PART == 1:
        try:
            overlay = Path(os.environ.get('CKA_LAB_STATE_DIR', ROOT / '.lab')) / 'evidence/W10-overlay'
            rendered = list(yaml.safe_load_all(subprocess.check_output(
                ['kubectl', 'kustomize', str(overlay)], stderr=subprocess.DEVNULL)))
        except (OSError, subprocess.CalledProcessError, yaml.YAMLError):
            rendered = []
        good = (len(rendered) == 1 and rendered[0].get('kind') == 'HorizontalPodAutoscaler'
                and rendered[0].get('metadata', {}).get('namespace') == NS
                and rendered[0].get('metadata', {}).get('name') == 'ember-autoscale'
                and rendered[0].get('metadata', {}).get('labels', {}).get('cka-lab.io/owner') == OWNER
                and all(rendered[0].get('spec', {}).get(key) == s.get(key) for key in ('scaleTargetRef', 'minReplicas', 'maxReplicas', 'metrics'))
                and s.get('scaleTargetRef') == {'apiVersion': 'apps/v1', 'kind': 'Deployment', 'name': 'ember-autoscale'}
                and s.get('minReplicas') == 1 and s.get('maxReplicas') == 3 and s.get('metrics') == metric)
    else:
        obj = get('hpa', 'ember-autoscale'); dep = spec('deployment', 'ember-autoscale')
        good = (owned(obj) and container(dep).get('resources', {}).get('requests', {}).get('cpu') == '20m'
                and any(c.get('type') == 'AbleToScale' and c.get('status') == 'True' for c in obj.get('status', {}).get('conditions', [])))
elif TASK == 'W11':
    ps = spec('pod', 'ember-guard'); c = (ps.get('containers') or [{}])[0]
    if PART == 1:
        good = (c.get('image') == 'busybox:1.36' and c.get('readinessProbe', {}).get('tcpSocket', {}).get('port') == 8080
                and c.get('livenessProbe', {}).get('tcpSocket', {}).get('port') == 8080
                and c.get('securityContext', {}).get('runAsUser') == 10001
                and c.get('securityContext', {}).get('allowPrivilegeEscalation') is False)
    else:
        good = running('ember-guard') and c.get('command') == ['httpd', '-f', '-p', '8080']
elif TASK == 'W12':
    ps = spec('pod', 'ember-composed'); init = ps.get('initContainers', []); containers = ps.get('containers', [])
    if PART == 1:
        good = (len(init) == 1 and init[0].get('name') == 'prepare' and init[0].get('image') == 'busybox:1.36'
                and {c.get('name') for c in containers} == {'main', 'sidecar'} and len(containers) == 2
                and ps.get('volumes') == [{'name': 'shared', 'emptyDir': {}}]
                and all(c.get('image') == 'busybox:1.36' and c.get('volumeMounts') == [{'name': 'shared', 'mountPath': '/shared'}] for c in init + containers))
    else:
        good = (running('ember-composed') and bool(init) and init[0].get('command') == ['sh', '-c', 'echo ready > /shared/seed']
                and next((c for c in containers if c.get('name') == 'main'), {}).get('command') == ['sh', '-c', 'test -f /shared/seed && sleep 7d']
                and next((c for c in containers if c.get('name') == 'sidecar'), {}).get('command') == ['sh', '-c', 'sleep 7d'])
elif TASK == 'W13':
    s = spec('poddisruptionbudget', 'ember-api'); obj = get('poddisruptionbudget', 'ember-api')
    if PART == 1:
        good = s.get('minAvailable') == 1 and 'maxUnavailable' not in s and s.get('selector') == {'matchLabels': {'app': 'ember-api'}}
    else:
        good = owned(obj) and ready('deployment', 'ember-api', 2) and obj.get('status', {}).get('currentHealthy') == 2 and obj.get('status', {}).get('disruptionsAllowed', 0) >= 1
else:
    raise ValueError(TASK)
sys.exit(0 if good else 1)
