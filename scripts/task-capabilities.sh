#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/common.sh"
NAMESPACE="${CKA_LAB_NAMESPACE:?}"
STATE_DIR="${CKA_LAB_STATE_DIR:?}"
metrics=false; networkpolicy=false; ingress=false; gateway=false; storageclass=false; expandable=false; helm=false; talosctl=false
kubectl get --raw /apis/metrics.k8s.io/v1beta1 >/dev/null 2>&1 && kubectl top nodes >/dev/null 2>&1 && kubectl top pods -n "$NAMESPACE" >/dev/null 2>&1 && metrics=true || :
# API presence alone does not prove enforcement. Recognized CNI pods provide a conservative hint.
if kubectl api-resources --api-group=networking.k8s.io -o name | grep -qx networkpolicies; then
  if kubectl get pods -A -o name 2>/dev/null | grep -Eiq '(cilium|calico|weave|antrea)'; then networkpolicy=true; fi
fi
kubectl get ingressclass >/dev/null 2>&1 && [[ -n "$(kubectl get ingressclass -o name 2>/dev/null)" ]] && ingress=true || :
# Only an accepted/programmed HTTP listener allowing same-namespace routes counts.
if has_httproutes; then
  while read -r gw; do
    [[ -n "$gw" ]] || continue
    if kubectl get "$gw" -n "$NAMESPACE" -o json | python3 "$ROOT/scripts/check_resource.py" gateway; then
      gateway=true; break
    fi
  done < <(kubectl get gateway.gateway.networking.k8s.io -n "$NAMESPACE" -o name 2>/dev/null || true)
fi
# No default class is automatically authorized for persistent lab data. An operator
# must explicitly approve one known disposable backend and its manual cleanup plan.
selected_sc="${CKA_LAB_STORAGE_CLASS:-}"
if [[ "${CKA_LAB_STORAGE_APPROVED:-false}" == true && "$selected_sc" =~ ^[a-z0-9]([-a-z0-9.]*[a-z0-9])?$ ]]; then
  if sc_json="$(kubectl get storageclass "$selected_sc" -o json 2>/dev/null)"; then
    if python3 -c 'import json,sys; x=json.load(sys.stdin); assert x["provisioner"] not in ("kubernetes.io/no-provisioner", ""); assert x.get("reclaimPolicy") == "Delete"; assert x.get("volumeBindingMode") in ("Immediate", "WaitForFirstConsumer")' <<<"$sc_json" 2>/dev/null; then
      storageclass=true
      if python3 -c 'import json,sys; assert json.load(sys.stdin).get("allowVolumeExpansion") is True' <<<"$sc_json" 2>/dev/null; then expandable=true; fi
    fi
  fi
fi
command -v helm >/dev/null 2>&1 && helm=true || :
command -v talosctl >/dev/null 2>&1 && talosctl get members -o json >/dev/null 2>&1 && talosctl=true || :
debug=false
[[ "$(kubectl auth can-i update pods/ephemeralcontainers -n "$NAMESPACE" 2>/dev/null)" == yes ]] && debug=true || :
{
  printf 'METRICS=%s\nNETWORKPOLICY=%s\nINGRESS=%s\nGATEWAY=%s\nSTORAGECLASS=%s\nEXPANDABLE=%s\nCKA_LAB_STORAGE_CLASS=%q\nHELM=%s\nTALOSCTL=%s\nDEBUG=%s\n' \
    "$metrics" "$networkpolicy" "$ingress" "$gateway" "$storageclass" "$expandable" "$selected_sc" "$helm" "$talosctl" "$debug"
} >"$STATE_DIR/capabilities.env"
