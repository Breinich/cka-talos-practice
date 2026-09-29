#!/usr/bin/env python3
"""Fail-closed, namespace-per-task lifecycle. Never performs cluster-scoped writes."""
import fcntl
import json
import os
from pathlib import Path
import re
import shutil
import secrets
import subprocess
import sys
import tempfile

import yaml

ROOT = Path(__file__).resolve().parents[1]
OWNER = 'cka-talos-practice'
OFFLINE = {'A06', 'A07', 'A11', 'A12', 'A13', 'A16', 'A17', 'A18', 'W09',
           'N04', 'N05', 'N06', 'N07', 'N09', 'N11', 'S02', 'S06', 'T07'}
# These tasks inspect shared cluster state but create no namespace or objects.
READ_ONLY = {'A01', 'A09', 'A10', 'A14', 'S04', 'T09', 'T11'}


def abort(reason):
    raise RuntimeError(reason)


def cmd(*args, input=None):
    return subprocess.run(['kubectl', *args], input=input, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True).stdout


def obj(*args):
    return json.loads(cmd(*args, '-o', 'json'))


def atomic(path, data):
    fd, name = tempfile.mkstemp(prefix='.state-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as stream:
            os.fchmod(stream.fileno(), 0o600)
            json.dump(data, stream)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def scope(id, domain, args):
    prefix = os.getenv('CKA_LAB_PREFIX', 'cka-practice')
    namespace = os.getenv('CKA_LAB_NAMESPACE', '')
    yes = False
    i = 0
    while i < len(args):
        if args[i] == '--yes':
            yes = True
        elif args[i] in ('--prefix', '--namespace') and i + 1 < len(args):
            i += 1
            if args[i - 1] == '--prefix':
                prefix = args[i]
            else:
                namespace = args[i]
        else:
            abort('usage: setup|teardown ID [--yes] [--prefix NAME] [--namespace NAME]')
        i += 1
    namespace = namespace or f'{prefix}-{id.lower()}'
    for value in (prefix, namespace):
        if not re.fullmatch(r'[a-z0-9]([-a-z0-9]*[a-z0-9])?', value) or not 3 <= len(value) <= 63:
            abort('unsafe DNS namespace/prefix')
    if namespace != f'{prefix}-{id.lower()}' and not namespace.startswith(f'{prefix}-'):
        abort('custom namespace must begin with prefix-')
    state_root = Path(os.getenv('CKA_TASK_STATE_ROOT', ROOT / '.lab')) / id / namespace
    return prefix, namespace, state_root, yes


def identity(yes):
    context = cmd('config', 'current-context').strip()
    server = cmd('config', 'view', '--minify', '-o', "jsonpath={.clusters[0].cluster.server}").strip()
    if not context or not server:
        abort('missing kubectl context/server')
    if context != 'admin@lake' and not yes:
        abort('unexpected context; inspect target, then use --yes')
    cmd('cluster-info')
    return {'context': context, 'server': server}


def namespace_object(ns):
    try:
        return obj('get', 'namespace', ns)
    except subprocess.CalledProcessError as error:
        if 'NotFound' in error.stderr or 'not found' in error.stderr:
            return None
        abort('cannot inspect namespace; refusing to assume it is absent')


def assert_namespace(item, state, id, ns, prefix):
    if not item:
        abort('saved namespace missing; refusing cleanup')
    m = item['metadata']
    labels = m.get('labels', {})
    if (m.get('uid') != state['uid'] or m.get('name') != ns or
        labels.get('cka-lab.io/owner') != OWNER or
        labels.get('cka-lab.io/task') != id or
        labels.get('cka-lab.io/prefix') != prefix or
        m.get('annotations', {}).get('cka-lab.io/instance') != state['instance']):
        abort('namespace UID/identity mismatch')


def load_state(file, id, prefix, ns, current):
    try:
        data = json.loads(file.read_text())
    except (OSError, ValueError):
        abort('missing or invalid saved state; refusing adoption/deletion')
    if (data.get('task') != id or data.get('prefix') != prefix or
        data.get('namespace') != ns or data.get('identity') != current or
        data.get('namespace_existed') is not False or not data.get('uid') or
        not re.fullmatch(r'[0-9a-f]{32}', data.get('instance', ''))):
        abort('saved identity/creation evidence mismatch')
    return data


def storage_guard(ns):
    # Inspect ALL claims and volumes, including objects not labelled as ours.
    claims = obj('get', 'persistentvolumeclaims', '-n', ns)['items']
    volumes = obj('get', 'persistentvolumes')['items']
    if claims or any(p.get('spec', {}).get('claimRef', {}).get('namespace') == ns for p in volumes):
        abort('PVC/PV present: manually review data, reclaim policy and backing storage; --yes cannot remove storage')


def ownership_guard(ns, id):
    kinds = cmd('api-resources', '--namespaced=true', '--verbs=list', '-o', 'name').splitlines()
    if not kinds:
        abort('empty API discovery; refusing deletion')
    records = []
    for kind in kinds:
        records.extend(obj('get', kind, '-n', ns)['items'])
    owned = {r['metadata']['uid'] for r in records if
             r['metadata'].get('labels', {}).get('cka-lab.io/owner') == OWNER and
             r['metadata'].get('labels', {}).get('cka-lab.io/task') == id}
    # Kubernetes-generated descendants inherit their owner's UID; Events and
    # EndpointSlices can also be generated without an ownerReference.
    services = {r['metadata']['name'] for r in records if r.get('kind') == 'Service' and r['metadata']['uid'] in owned}
    for r in records:
        m = r['metadata']
        if m.get('uid') in owned:
            continue
        if r.get('kind') == 'Event' or m.get('name') in ('default', 'kube-root-ca.crt') and r.get('kind') in ('ServiceAccount', 'ConfigMap'):
            continue
        if any(ref.get('uid') in owned for ref in m.get('ownerReferences', [])):
            continue
        if (r.get('kind') == 'Endpoints' and m.get('name') in services and
                any(field.get('manager') in ('kube-controller-manager', 'endpoints-controller')
                    for field in m.get('managedFields', []))):
            continue  # legacy controller-managed Service endpoints lack ownerReferences
        if (r.get('kind') == 'EndpointSlice' and m.get('labels', {}).get('kubernetes.io/service-name') in services
                and m.get('labels', {}).get('endpointslice.kubernetes.io/managed-by') == 'endpointslice-controller.k8s.io'):
            continue
        abort(f'unowned {r.get("kind")}/{m.get("name")} blocks namespace deletion')


def seed(id, domain, ns, prefix):
    path = ROOT / 'tasks' / domain / id / 'resources' / 'seed.yaml'
    if not path.exists():
        return
    raw = path.read_text().replace('__NAMESPACE__', ns).replace('__PREFIX__', prefix)
    docs = list(yaml.safe_load_all(raw))
    replace_pods = []
    # Preflight every name before any delete or apply. A collision later in the
    # manifest must not cause an earlier immutable starter Pod to be removed.
    for doc in docs:
        m = doc['metadata']
        if (m['namespace'] != ns or m['labels'].get('cka-lab.io/owner') != OWNER or
                m['labels'].get('cka-lab.io/task') != id):
            abort('invalid seed scope')
        kind, name = doc['kind'], m['name']
        try:
            existing = obj('get', kind, name, '-n', ns)
        except subprocess.CalledProcessError as error:
            if 'NotFound' not in error.stderr and 'not found' not in error.stderr:
                abort('cannot inspect seed collision')
            existing = None
        if existing and (existing['metadata'].get('labels', {}).get('cka-lab.io/owner') != OWNER or
                         existing['metadata'].get('labels', {}).get('cka-lab.io/task') != id):
            abort(f'unowned seed collision: {kind}/{name}')
        # Pod specs are immutable; replace only our individually checked seed.
        if existing and kind == 'Pod':
            replace_pods.append(name)
    for name in replace_pods:
        cmd('delete', 'pod', name, '-n', ns, '--wait=true')
    cmd('apply', '-f', '-', input=raw)
    if id == 'W03':
        cmd('rollout', 'status', 'deployment/ember-recovery', '-n', ns, '--timeout=90s')
        cmd('set', 'image', 'deployment/ember-recovery', 'api=nginx:no-such-tag-cka-practice', '-n', ns)


def clear_attempt(directory):
    # Reset may discard only this task instance's local submissions and overlay.
    # Refuse symlinked roots before touching the cluster or another directory.
    for path in (directory / 'evidence', directory / 'A08-kustomize'):
        if path.is_symlink():
            abort('symlinked task evidence/overlay; refusing reset')
    for path in (directory / 'evidence', directory / 'A08-kustomize'):
        if path.exists():
            shutil.rmtree(path)
    (directory / 'capabilities.env').unlink(missing_ok=True)


def main():
    operation, id, *args = sys.argv[1:]
    import csv
    with (ROOT / 'metadata/tasks.tsv').open() as stream:
        tasks = {row['id']: row['domain'] for row in csv.DictReader(stream, delimiter='\t')}
    if operation not in ('setup', 'teardown', 'reset') or id not in tasks:
        abort('unknown operation or task ID')
    prefix, ns, directory, yes = scope(id, tasks[id], args)
    if directory.is_symlink() or directory.parent.is_symlink():
        abort('symlinked task state; refusing lifecycle operation')
    directory.mkdir(parents=True, exist_ok=True, mode=0o700)
    os.chmod(directory, 0o700)
    with (directory / '.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        state_file = directory / 'state.json'
        if id in OFFLINE:
            if state_file.exists():
                abort('offline task has unexpected cluster state')
            if operation == 'reset':
                clear_attempt(directory)
            if operation in ('setup', 'reset'):
                (directory / 'evidence').mkdir(exist_ok=True, mode=0o700)
            return
        current = identity(yes)
        if id in READ_ONLY:
            if state_file.exists():
                abort('read-only task has unexpected cluster state')
            if operation == 'reset':
                clear_attempt(directory)
            if operation in ('setup', 'reset'):
                (directory / 'evidence').mkdir(exist_ok=True, mode=0o700)
                subprocess.run(['bash', str(ROOT / 'scripts/task-capabilities.sh')], check=True)
            return
        namespace = namespace_object(ns)
        if operation == 'reset':
            state = load_state(state_file, id, prefix, ns, current)
            assert_namespace(namespace, state, id, ns, prefix)
            # A failed storage/ownership/symlink preflight must retain both the
            # namespace and submissions; reset grants no extra delete authority.
            for path in (directory / 'evidence', directory / 'A08-kustomize'):
                if path.is_symlink():
                    abort('symlinked task evidence/overlay; refusing reset')
            storage_guard(ns)
            ownership_guard(ns, id)
            cmd('delete', 'namespace', ns, '--wait=true')
            state_file.unlink()
            clear_attempt(directory)
            namespace = None
            operation = 'setup'
        if operation == 'setup' and not state_file.exists():
            if namespace:
                abort('namespace already exists: never adopt, even if labelled; use another namespace')
            # Create atomically with identity labels. If interrupted before state is
            # written, future setup/teardown refuses the namespace (manual recovery).
            instance = secrets.token_hex(16)
            manifest = {'apiVersion': 'v1', 'kind': 'Namespace', 'metadata': {'name': ns,
                'annotations': {'cka-lab.io/instance': instance},
                'labels': {'cka-lab.io/owner': OWNER, 'cka-lab.io/prefix': prefix,
                           'cka-lab.io/task': id}}}
            if id == 'A15':
                manifest['metadata']['labels'].update({
                    'pod-security.kubernetes.io/audit': 'baseline',
                    'pod-security.kubernetes.io/warn': 'baseline'})
            cmd('create', '-f', '-', input=yaml.safe_dump(manifest))
            namespace = namespace_object(ns)
            if not namespace or not namespace.get('metadata', {}).get('uid'):
                abort('namespace created but UID unavailable: manual recovery required')
            state = {'task': id, 'prefix': prefix, 'namespace': ns, 'identity': current,
                     'namespace_existed': False, 'uid': namespace['metadata']['uid'],
                     'instance': instance}
            atomic(state_file, state)
        state = load_state(state_file, id, prefix, ns, current)
        assert_namespace(namespace, state, id, ns, prefix)
        if operation == 'teardown':
            storage_guard(ns)
            ownership_guard(ns, id)
            cmd('delete', 'namespace', ns, '--wait=true')
            state_file.unlink()
            return
        storage_guard(ns)  # Never reseed into a namespace containing persistent data.
        ownership_guard(ns, id)
        seed(id, tasks[id], ns, prefix)
        (directory / 'evidence').mkdir(exist_ok=True, mode=0o700)
        if id in ('A08', 'W10'):
            name = 'kustomize' if id == 'A08' else 'hpa'
            working = directory / 'A08-kustomize' if id == 'A08' else directory / 'evidence/W10-overlay'
            if not working.exists():
                shutil.copytree(ROOT / 'tasks' / tasks[id] / id / 'resources' / name, working)
        subprocess.run(['bash', str(ROOT / 'scripts/task-capabilities.sh')], check=True)
        print(f'Task {id} ready: namespace {ns}; evidence {directory / "evidence"}', file=sys.stderr)


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError, KeyError, ValueError, OSError) as error:
        # Never log command stdout/stderr: this may include a short-lived token.
        print(f'ERROR: {error if isinstance(error, RuntimeError) else type(error).__name__}', file=sys.stderr)
        sys.exit(1)
