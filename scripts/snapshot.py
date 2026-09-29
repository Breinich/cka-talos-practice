#!/usr/bin/env python3
"""Produce a restorable, owned-only Kubernetes List from kubectl JSON lists."""
import json
import os
import sys

if len(sys.argv) == 2 and sys.argv[1] == "--assert-owned":
    response = json.load(sys.stdin)
    if response.get("kind") != "List":
        raise ValueError("cannot inspect namespace resources")
    owned_services = set(os.environ.get("OWNED_SERVICES", "").splitlines())
    for obj in response["items"]:
        meta = obj.get("metadata", {})
        if meta.get("labels", {}).get("cka-lab.io/owner") == "cka-talos-practice":
            continue
        # Kubernetes creates these namespace defaults, not exercise objects.
        if (obj.get("kind"), meta.get("name")) in (("ConfigMap", "kube-root-ca.crt"), ("ServiceAccount", "default")):
            continue
        labels = meta.get("labels", {})
        if (obj.get("kind") == "EndpointSlice"
                and labels.get("endpointslice.kubernetes.io/managed-by") == "endpointslice-controller.k8s.io"
                and labels.get("kubernetes.io/service-name") in owned_services):
            continue
        raise ValueError(f"unowned {obj.get('kind')}/{meta.get('name')}; refusing namespace deletion")
    sys.exit(0)

if len(sys.argv) == 4 and sys.argv[1] == "--verify":
    with open(sys.argv[2], encoding="utf-8") as stream:
        baseline = json.load(stream)
    if baseline.get("kind") != "List" or not isinstance(baseline.get("items"), list):
        raise ValueError("baseline is not an owned JSON List; refusing restore")
    for obj in baseline["items"]:
        meta = obj.get("metadata", {})
        if (meta.get("namespace") != sys.argv[3]
                or meta.get("labels", {}).get("cka-lab.io/owner") != "cka-talos-practice"
                or obj.get("kind") in ("PersistentVolume", "PersistentVolumeClaim")
                or not obj.get("apiVersion") or not meta.get("name")):
            raise ValueError("unsafe baseline item; refusing restore")
    sys.exit(0)

items = []
for path in sys.argv[1:]:
    with open(path, encoding="utf-8") as stream:
        response = json.load(stream)
    if response.get("kind") != "List" or not isinstance(response.get("items"), list):
        raise ValueError(f"expected kubectl List in {path}")
    for obj in response["items"]:
        meta = obj["metadata"]
        if meta.get("labels", {}).get("cka-lab.io/owner") != "cka-talos-practice":
            continue
        # Controller-generated children are recreated by their owner, not restored independently.
        if meta.get("ownerReferences"):
            continue
        for key in ("uid", "resourceVersion", "generation", "creationTimestamp",
                    "managedFields", "selfLink", "deletionTimestamp", "deletionGracePeriodSeconds"):
            meta.pop(key, None)
        meta.get("annotations", {}).pop("kubectl.kubernetes.io/last-applied-configuration", None)
        obj.pop("status", None)
        items.append(obj)
json.dump({"apiVersion": "v1", "kind": "List", "items": items}, sys.stdout)
print()
