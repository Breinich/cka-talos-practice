#!/usr/bin/env python3
"""Read-only, exact storage criteria; never applies manifests or changes a claim."""
import json
import os
from pathlib import Path
import subprocess
import sys

import yaml

TASK, PART = sys.argv[1], int(sys.argv[2])
NAMESPACE = os.environ.get('CKA_LAB_NAMESPACE', os.environ.get('CKA_LAB_PREFIX', 'cka-practice'))
PREFIX = os.environ.get('CKA_LAB_PREFIX', 'cka-practice')
EVIDENCE = Path(os.environ.get('CKA_LAB_STATE_DIR', '.lab')) / 'evidence'
OWNER = 'cka-talos-practice'


def get(kind, name=None):
    args = ['kubectl', 'get', kind]
    if name:
        args.append(name)
    if kind not in ('storageclass', 'csidriver'):
        args += ['-n', NAMESPACE]
    return json.loads(subprocess.check_output(args + ['-o', 'json'], stderr=subprocess.DEVNULL))


def owned(obj):
    return obj.get('metadata', {}).get('labels', {}).get('cka-lab.io/owner') == OWNER


def offline(filename, kinds):
    docs = list(yaml.safe_load_all((EVIDENCE / filename).read_text()))
    assert len(docs) == len(kinds) and [d.get('kind') for d in docs] == kinds
    for d in docs:
        meta = d['metadata']
        assert owned(d) and (meta.get('namespace') == NAMESPACE if d['kind'] != 'PersistentVolume'
                             else meta.get('namespace') is None and meta['labels'].get('cka-lab.io/prefix') == PREFIX)
    return docs


def static_pair(pv, claim, suffix, capacity, mode):
    p, c = pv['spec'], claim['spec']
    assert pv['metadata']['name'] == f'{PREFIX}-lighthouse-{suffix}'
    assert claim['metadata']['name'] == f'lighthouse-{suffix}'
    assert p.get('hostPath') == {'path': f'/var/local/lighthouse-{suffix}', 'type': 'DirectoryOrCreate'}
    assert p.get('capacity', {}).get('storage') == capacity
    assert p.get('accessModes') == [mode] and c.get('accessModes') == [mode]
    assert p.get('storageClassName') == c.get('storageClassName') == ''
    assert c.get('volumeName') == pv['metadata']['name']
    assert c.get('resources', {}).get('requests', {}).get('storage') == capacity


def main():
    if TASK == 'S01':
        dep = get('deployment', 'lighthouse-workspace')
        podspec = dep['spec']['template']['spec']
        containers = {c['name']: c for c in podspec['containers']}
        assert owned(dep) and dep['spec']['replicas'] == 1 and set(containers) == {'producer', 'consumer'}
        assert podspec['volumes'] == [{'name': 'workspace', 'emptyDir': {}}]
        for c in containers.values():
            assert {'name': 'workspace', 'mountPath': '/workspace'} in c.get('volumeMounts', [])
        if PART == 2:
            assert dep['status']['observedGeneration'] >= dep['metadata']['generation']
            assert dep['status']['readyReplicas'] == 1
            pods = get('pods')['items']
            pods = [p for p in pods if owned(p) and p['metadata'].get('ownerReferences') and
                    p['metadata']['labels'].get('app') == 'lighthouse-workspace' and
                    p['status']['phase'] == 'Running' and
                    all(c.get('ready') for c in p['status'].get('containerStatuses', [])) and
                    len(p['status'].get('containerStatuses', [])) == 2]
            assert len(pods) == 1
            name = pods[0]['metadata']['name']
            content = subprocess.check_output(['kubectl', 'exec', '-n', NAMESPACE, name, '-c', 'consumer', '--',
                                               'cat', '/workspace/receipt'], stderr=subprocess.DEVNULL, timeout=5)
            assert content.strip() == b'lighthouse-ready'
    elif TASK == 'S02':
        pv, claim, pod = offline('S02-static.yaml', ['PersistentVolume', 'PersistentVolumeClaim', 'Pod'])
        static_pair(pv, claim, 'archive', '256Mi', 'ReadWriteOnce')
        assert pv['spec']['persistentVolumeReclaimPolicy'] == 'Retain'
        if PART == 2:
            spec = pod['spec']
            assert pod['metadata']['name'] == 'lighthouse-reader'
            assert spec['volumes'] == [{'name': 'archive', 'persistentVolumeClaim': {'claimName': 'lighthouse-archive'}}]
            assert len(spec['containers']) == 1 and spec['containers'][0]['name'] == 'reader'
            assert {'name': 'archive', 'mountPath': '/archive'} in spec['containers'][0]['volumeMounts']
    elif TASK == 'S04':
        saved = json.loads((EVIDENCE / 'S04.json').read_text())
        assert set(saved) == {'classes', 'drivers'}
        if PART == 1:
            actual = sorted([{'name': i['metadata']['name'], 'provisioner': i['provisioner'],
                              'reclaimPolicy': i['reclaimPolicy'], 'volumeBindingMode': i['volumeBindingMode'],
                              'allowVolumeExpansion': i.get('allowVolumeExpansion', False),
                              'isDefault': i['metadata'].get('annotations', {}).get('storageclass.kubernetes.io/is-default-class') == 'true'}
                             for i in get('storageclass')['items']], key=lambda i: i['name'])
            assert saved['classes'] == actual
        else:
            assert saved['drivers'] == sorted([i['metadata']['name'] for i in get('csidriver')['items']])
    elif TASK in ('S03', 'S05'):
        selected = os.environ.get('CKA_LAB_STORAGE_CLASS', '')
        assert selected
        pvc = get('pvc', 'lighthouse-live')
        spec, status = pvc['spec'], pvc['status']
        assert owned(pvc) and spec['storageClassName'] == selected and spec['accessModes'] == ['ReadWriteOnce']
        assert status['phase'] == 'Bound' and status.get('capacity', {}).get('storage')
        # Compare quantities in bytes, not strings: 128Mi and 134217728 are equivalent.
        def size(text):
            import re
            match = re.fullmatch(r'(\d+)(Mi|Gi)?', text)
            assert match
            return int(match[1]) * {'Mi': 2**20, 'Gi': 2**30, None: 1}[match[2]]
        target = 128 if TASK == 'S05' else 64
        assert target * 2**20 <= size(spec['resources']['requests']['storage']) <= 128 * 2**20
        assert size(status['capacity']['storage']) >= target * 2**20
        if PART == 2:
            pod = get('pod', 'lighthouse-live-reader')
            assert owned(pod) and pod['status']['phase'] == 'Running'
            assert pod['spec']['volumes'] == [{'name': 'data', 'persistentVolumeClaim': {'claimName': 'lighthouse-live'}}]
            assert len(pod['spec']['containers']) == 1
            container = pod['spec']['containers'][0]
            assert {'name': 'data', 'mountPath': '/data'} in container.get('volumeMounts', [])
            assert any(c['name'] == container['name'] and c['ready'] for c in pod['status'].get('containerStatuses', []))
            assert subprocess.check_output(['kubectl', 'exec', '-n', NAMESPACE, 'lighthouse-live-reader', '-c',
                                            container['name'], '--', 'cat', '/data/receipt'],
                                           stderr=subprocess.DEVNULL, timeout=5).strip() == b'lighthouse-live-ready'
    elif TASK == 'S06':
        pv, claim = offline('S06-reclaim.yaml', ['PersistentVolume', 'PersistentVolumeClaim'])
        static_pair(pv, claim, 'records', '128Mi', 'ReadWriteOnce')
        if PART == 2:
            assert pv['spec']['persistentVolumeReclaimPolicy'] == 'Retain'
    else:
        raise ValueError(TASK)


if __name__ == '__main__':
    try:
        main()
    except (AssertionError, KeyError, ValueError, OSError, subprocess.CalledProcessError,
            subprocess.TimeoutExpired, TypeError, IndexError):
        sys.exit(1)
