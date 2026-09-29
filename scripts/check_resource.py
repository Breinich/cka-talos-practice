#!/usr/bin/env python3
"""Check structural task criteria from read-only kubectl JSON (never print objects)."""
import json
import sys

obj = json.load(sys.stdin)
spec = obj.get("spec", {})

def scoped_peer(peer):
    return (bool(peer.get("podSelector", {}).get("matchLabels"))
            or bool(peer.get("namespaceSelector", {}).get("matchLabels"))
            or bool(peer.get("ipBlock", {}).get("cidr") not in (None, "0.0.0.0/0", "::/0")))


def rules_valid(rules, direction):
    return bool(rules) and all(
        isinstance(rule.get(direction), list) and rule[direction]
        and all(scoped_peer(peer) for peer in rule[direction])
        and rule.get("ports") and all(p.get("port") for p in rule["ports"])
        for rule in rules
    )

mode = sys.argv[1]
if mode == "arch-role":
    rules = spec.get("rules", obj.get("rules", []))
    good = (len(rules) == 1 and rules[0].get("apiGroups") == [""]
            and rules[0].get("resources") == ["pods"]
            and set(rules[0].get("verbs", [])) == {"get", "list", "watch"}
            and obj.get("metadata", {}).get("labels", {}).get("cka-lab.io/owner") == "cka-talos-practice")
elif mode == "arch-binding":
    good = (obj.get("roleRef") == {"apiGroup": "rbac.authorization.k8s.io", "kind": "Role", "name": "relay-reader"}
            and obj.get("subjects") == [{"kind": "ServiceAccount", "name": "relay-identity", "namespace": obj.get("metadata", {}).get("namespace")}]
            and obj.get("metadata", {}).get("labels", {}).get("cka-lab.io/owner") == "cka-talos-practice")
elif mode == "arch-pod":
    containers = spec.get("containers", [])
    good = (spec.get("serviceAccountName") == "relay-identity"
            and spec.get("automountServiceAccountToken") is False
            and len(containers) == 1 and containers[0].get("image") == "busybox:1.36"
            and containers[0].get("command", [None])[0] in ("sleep", "sh")
            and obj.get("metadata", {}).get("labels", {}).get("cka-lab.io/owner") == "cka-talos-practice")
elif mode == "default-deny":
    good = (set(spec.get("policyTypes", [])) == {"Ingress", "Egress"}
            and spec.get("podSelector") == {}
            and not spec.get("ingress") and not spec.get("egress"))
elif mode == "allow-web":
    good = (bool(spec.get("podSelector"))
            and rules_valid(spec.get("ingress"), "from")
            and rules_valid(spec.get("egress"), "to"))
elif mode == "cronjob":
    good = (spec.get("suspend") is True and bool(spec.get("schedule"))
            and all(isinstance(spec.get(k), int) and spec[k] >= 0
                    for k in ("successfulJobsHistoryLimit", "failedJobsHistoryLimit")))
elif mode == "gateway":
    conditions = {c.get("type"): c.get("status") for c in obj.get("status", {}).get("conditions", [])}
    good = conditions.get("Programmed") == "True" and any(
        listener.get("protocol") in ("HTTP", "HTTPS")
        and listener.get("allowedRoutes", {}).get("namespaces", {}).get("from", "Same") in ("Same", "All")
        and "HTTPRoute" in [k.get("kind") for k in listener.get("allowedRoutes", {}).get("kinds", [{"kind": "HTTPRoute"}])]
        and any(status.get("name") == listener.get("name")
                and {c.get("type"): c.get("status") for c in status.get("conditions", [])}.get("Accepted") == "True"
                and {c.get("type"): c.get("status") for c in status.get("conditions", [])}.get("Programmed") == "True"
                for status in obj.get("status", {}).get("listeners", []))
        for listener in spec.get("listeners", []))
elif mode == "route":
    refs = spec.get("parentRefs", [])
    backend = [b.get("name") for rule in spec.get("rules", []) for b in rule.get("backendRefs", [])]
    good = bool(refs and "web" in backend and any(
        parent.get("parentRef", {}).get("name") == ref.get("name")
        and parent.get("parentRef", {}).get("namespace", obj["metadata"]["namespace"]) == obj["metadata"]["namespace"]
        and {c.get("type"): c.get("status") for c in parent.get("conditions", [])}.get("Accepted") == "True"
        and {c.get("type"): c.get("status") for c in parent.get("conditions", [])}.get("ResolvedRefs") == "True"
        for parent in obj.get("status", {}).get("parents", []) for ref in refs
        if ref.get("kind", "Gateway") == "Gateway"))
else:
    raise ValueError(f"unknown criterion: {mode}")
sys.exit(0 if good else 1)
