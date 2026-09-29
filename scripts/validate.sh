#!/usr/bin/env bash
# Deterministic, read-only scorer. It never creates or changes cluster resources.
set -o nounset -o pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/common.sh"
set +o errexit
FORMAT=human; REQUEST=all
while (($#)); do
  case "$1" in
    --json) FORMAT=json;;
    --task) shift; REQUEST="${1:-}";;
    -h|--help) echo "usage: $0 [--task ID|all] [--json]"; exit 0;;
    *) die "unknown option: $1";;
  esac; shift
done
need kubectl; need python3; validate_scope
META="$ROOT/metadata/tasks.tsv"; EVIDENCE="$STATE_DIR/evidence"
CAP="$STATE_DIR/capabilities.env"
METRICS=false; NETWORKPOLICY=false; INGRESS=false; GATEWAY=false; STORAGECLASS=false; EXPANDABLE=false; HELM=false; TALOSCTL=false
[[ -r "$CAP" ]] && source "$CAP"

TOTAL=0; EARNED=0; RESULTS=(); CUR=; MAX=0; CHECKS=0; GOOD=0
meta_line() { awk -F '\t' -v id="$1" 'NR>1 && $1==id {print; exit}' "$META"; }
begin() { CUR="$1"; MAX="$2"; CHECKS=0; GOOD=0; }
check() { CHECKS=$((CHECKS+1)); "$@" >/dev/null 2>&1 && GOOD=$((GOOD+1)); return 0; }
json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/[[:cntrl:]]/ /g'; }
finish() {
  local status score
  if ((GOOD == CHECKS)); then status=PASS; score=$MAX
  elif ((GOOD == 0)); then status=FAIL; score=0
  else status=PARTIAL; score=$((MAX * GOOD / CHECKS))
  fi
  TOTAL=$((TOTAL+MAX)); EARNED=$((EARNED+score))
  RESULTS+=("$CUR|$status|$score|$MAX|$GOOD/$CHECKS")
}
skip() { RESULTS+=("$1|$2|0|$3|0/0"); }
evidence_has() { local f="$EVIDENCE/$1.txt"; [[ -s "$f" ]] && grep -Eiq "$2" "$f"; }
getj() { kubectl get "$1" "$2" -n "$NAMESPACE" -o "jsonpath=$3" 2>/dev/null; }
ready_endpoint_for() {
  kubectl get endpointslice -n "$NAMESPACE" -l "kubernetes.io/service-name=$1" \
    -o jsonpath='{range .items[*].endpoints[*]}{.conditions.ready}{"|"}{.addresses[0]}{"\n"}{end}' 2>/dev/null |
    grep -Eq '^true\|.+'
}
resource_check() { kubectl get "$1" "$2" -n "$NAMESPACE" -o json | python3 "$ROOT/scripts/check_resource.py" "$3"; }
policy_pair() { resource_check networkpolicy default-deny default-deny && resource_check networkpolicy allow-web allow-web; }
export -f getj
export NAMESPACE PREFIX

validate_task() {
  local id="$1" line domain max mode req title v
  line="$(meta_line "$id")"; [[ -n "$line" ]] || { log "unknown task: $id"; return 2; }
  IFS=$'\t' read -r id domain max mode req title <<<"$line"
  case "$mode:$req" in
    disposable-kubeadm:*) skip "$id" UNSUPPORTED "$max"; return;;
    read-only:talosctl) [[ "$TALOSCTL" == true ]] || { skip "$id" UNSUPPORTED "$max"; return; };;
    conditional:metrics) [[ "$METRICS" == true ]] || { skip "$id" SKIP "$max"; return; };;
    conditional:networkpolicy) [[ "$NETWORKPOLICY" == true ]] || { skip "$id" SKIP "$max"; return; };;
    conditional:ingress) [[ "$INGRESS" == true ]] || { skip "$id" SKIP "$max"; return; };;
    conditional:gateway) [[ "$GATEWAY" == true ]] || { skip "$id" SKIP "$max"; return; };;
    conditional:storageclass) [[ "$STORAGECLASS" == true ]] || { skip "$id" SKIP "$max"; return; };;
    conditional:expandable) [[ "$EXPANDABLE" == true ]] || { skip "$id" SKIP "$max"; return; };;
    simulation:helm) [[ "$HELM" == true ]] || { skip "$id" UNSUPPORTED "$max"; return; };;
  esac
  case "$id" in
    A01) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A02) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A06) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A07) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A08) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A09) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A10) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A11) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A14) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A15) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A16) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A17) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A18) begin "$id" "$max"; check python3 "$ROOT/scripts/check_architecture.py" "$id" 1; check python3 "$ROOT/scripts/check_architecture.py" "$id" 2; finish;;
    A03) begin "$id" "$max"; check resource_check role relay-reader arch-role; check resource_check rolebinding relay-reader arch-binding; finish;;
    A04) begin "$id" "$max"; check resource_check pod relay-consumer arch-pod; check bash -c "[[ \$(getj pod relay-consumer '{.status.phase}') == Running ]]"; finish;;
    A05) begin "$id" "$max"; check bash -c "[[ \$(kubectl auth can-i list pods -n '$NAMESPACE' --as=system:serviceaccount:'$NAMESPACE':relay-identity) == yes ]]"; check bash -c "[[ \$(kubectl auth can-i delete pods -n '$NAMESPACE' --as=system:serviceaccount:'$NAMESPACE':relay-identity) == no ]]"; finish;;
    W01) begin "$id" "$max"; check kubectl get deploy resource-app -n "$NAMESPACE"; check bash -c "[[ -n \$(getj deploy resource-app '{.spec.template.spec.containers[0].resources.requests.cpu}') && -n \$(getj deploy resource-app '{.spec.template.spec.containers[0].resources.limits.memory}') ]]"; finish;;
    W02) begin "$id" "$max"; check bash -c "[[ \$(getj deploy rollout-app '{.spec.strategy.type}') == RollingUpdate ]]"; check bash -c "kubectl rollout status deploy/rollout-app -n '$NAMESPACE' --timeout=1s"; finish;;
    W03) begin "$id" "$max"; check bash -c "kubectl rollout history deploy/rollout-app -n '$NAMESPACE' | grep -Eq '[2-9]'"; check bash -c "kubectl rollout status deploy/rollout-app -n '$NAMESPACE' --timeout=1s"; finish;;
    W04) begin "$id" "$max"; check bash -c "[[ \$(getj job one-shot '{.status.conditions[?(@.type==\"Complete\")].status}') == True ]]"; check resource_check cronjob periodic cronjob; finish;;
    W05) begin "$id" "$max"; check kubectl get ds node-agent -n "$NAMESPACE"; check bash -c "desired=\$(getj ds node-agent '{.status.desiredNumberScheduled}'); ready=\$(getj ds node-agent '{.status.numberReady}'); [[ \$desired =~ ^[0-9]+$ && \$ready =~ ^[0-9]+$ && \$desired -gt 0 && \$ready -eq \$desired ]]"; finish;;
    W06) begin "$id" "$max"; check bash -c "[[ \$(getj sts ordered-app '{.spec.serviceName}') == ordered-app ]]"; check bash -c "[[ \$(getj svc ordered-app '{.spec.clusterIP}') == None ]]"; finish;;
    W07) begin "$id" "$max"; check bash -c "kubectl get cm app-config -n '$NAMESPACE' >/dev/null && kubectl get secret app-secret -n '$NAMESPACE' >/dev/null"; check bash -c "v=\$(kubectl get pod config-consumer -n '$NAMESPACE' -o yaml 2>/dev/null); grep -q app-config <<<\"\$v\" && grep -q app-secret <<<\"\$v\""; finish;;
    W08) begin "$id" "$max"; check bash -c "[[ -n \$(getj deploy affinity-app '{.spec.template.spec.affinity.nodeAffinity}') ]]"; check bash -c "[[ -n \$(getj deploy affinity-app '{.spec.template.spec.affinity.podAntiAffinity}') ]]"; finish;;
    W09) begin "$id" "$max"; check bash -c "[[ -n \$(getj pod tolerant-app '{.spec.tolerations[0].key}') ]]"; check evidence_has W09 'taint|NoSchedule'; finish;;
    W10) begin "$id" "$max"; check kubectl get hpa web-hpa -n "$NAMESPACE"; check bash -c "[[ \$(getj hpa web-hpa '{.spec.maxReplicas}') -ge 2 ]]"; finish;;
    W11) begin "$id" "$max"; check bash -c "[[ -n \$(getj pod hardened-app '{.spec.containers[0].readinessProbe}') ]]"; check bash -c "[[ \$(getj pod hardened-app '{.spec.containers[0].securityContext.allowPrivilegeEscalation}') == false ]]"; finish;;
    W12) begin "$id" "$max"; check bash -c "[[ -n \$(getj pod composed-app '{.spec.initContainers[0].name}') ]]"; check bash -c "[[ \$(getj pod composed-app '{.spec.containers[*].name}') == *sidecar* ]]"; finish;;
    W13) begin "$id" "$max"; check bash -c "[[ \$(getj pdb resource-app '{.spec.minAvailable}') == 1 ]]"; check evidence_has W13 'voluntary|involuntary'; finish;;
    N01) begin "$id" "$max"; check bash -c "[[ \$(getj svc app-service '{.spec.type}') == ClusterIP ]]"; check ready_endpoint_for app-service; finish;;
    N02) begin "$id" "$max"; check bash -c "[[ \$(getj svc ordered-headless '{.spec.clusterIP}') == None ]]"; check evidence_has N02 'ordered-headless'; finish;;
    N03) begin "$id" "$max"; check evidence_has N03 'endpoint|address'; check evidence_has N03 'selector|label'; finish;;
    N04) begin "$id" "$max"; check evidence_has N04 'cluster.local|svc'; check evidence_has N04 'address|name'; finish;;
    N05) begin "$id" "$max"; check policy_pair; check bash -c "f='$EVIDENCE/N05.txt'; [[ -s \"\$f\" ]] && grep -Eiq 'allow|success|connected|200' \"\$f\" && grep -Eiq 'deny|timeout|blocked|failed' \"\$f\""; finish;;
    N06) begin "$id" "$max"; check kubectl get ingress web-ingress -n "$NAMESPACE"; check bash -c "[[ -n \$(getj ingress web-ingress '{.spec.rules[0].http.paths[0].backend.service.name}') ]]"; finish;;
    N07) begin "$id" "$max"; check bash -c "[[ -n \$(getj httproute web-route '{.spec.parentRefs[0].name}') && \$(getj httproute web-route '{.spec.rules[0].backendRefs[0].name}') == web ]]"; check resource_check httproute web-route route; finish;;
    N08) begin "$id" "$max"; check bash -c "[[ \$(getj svc port-fixed '{.spec.ports[0].targetPort}') == http ]]"; check ready_endpoint_for port-fixed; finish;;
    N09) begin "$id" "$max"; check evidence_has N09 'cilium|calico|flannel|antrea|cni'; check evidence_has N09 'proxy|ebpf|iptables|ipvs'; finish;;
    N10) begin "$id" "$max"; check evidence_has N10 'port-forward'; check evidence_has N10 '200|welcome|nginx'; finish;;
    N11) begin "$id" "$max"; check grep -Eq 'type:[[:space:]]*NodePort' "$EVIDENCE/N11-services.yaml"; check grep -Eq 'type:[[:space:]]*ExternalName' "$EVIDENCE/N11-services.yaml"; finish;;
    S01) begin "$id" "$max"; check bash -c "[[ -n \$(getj pod scratch-app '{.spec.volumes[0].emptyDir}') ]]"; check bash -c "[[ -n \$(getj pod scratch-app '{.spec.containers[0].volumeMounts[0].mountPath}') ]]"; finish;;
    S02) begin "$id" "$max"; check bash -c "grep -Eq '^kind: PersistentVolume$' '$EVIDENCE/S02-static.yaml' && grep -Eq '^kind: PersistentVolumeClaim$' '$EVIDENCE/S02-static.yaml' && grep -Eq '^kind: Pod$' '$EVIDENCE/S02-static.yaml'"; check bash -c "grep -q 'cka-lab.io/owner: cka-talos-practice' '$EVIDENCE/S02-static.yaml' && grep -q 'cka-lab.io/prefix: $PREFIX' '$EVIDENCE/S02-static.yaml' && grep -q 'volumeName:' '$EVIDENCE/S02-static.yaml'"; finish;;
    S03) begin "$id" "$max"; check kubectl get pvc dynamic-claim -n "$NAMESPACE"; check bash -c "[[ \$(getj pvc dynamic-claim '{.status.phase}') == Bound ]]"; finish;;
    S04) begin "$id" "$max"; check evidence_has S04 'storageclass'; check evidence_has S04 'csi|provisioner'; finish;;
    S05) begin "$id" "$max"; check kubectl get pvc expandable-claim -n "$NAMESPACE"; check evidence_has S05 'resize|capacity|expand'; finish;;
    S06) begin "$id" "$max"; check evidence_has S06 'ReadWriteOnce|ReadOnlyMany|ReadWriteMany'; check evidence_has S06 'Retain|Delete|reclaim'; finish;;
    T01) begin "$id" "$max"; check bash -c "kubectl rollout status deploy/broken-image -n '$NAMESPACE' --timeout=1s"; check bash -c "[[ \$(getj deploy broken-image '{.spec.template.spec.containers[0].image}') != *no-such* ]]"; finish;;
    T02) begin "$id" "$max"; check bash -c "kubectl rollout status deploy/broken-ready -n '$NAMESPACE' --timeout=1s"; check bash -c "[[ \$(getj deploy broken-ready '{.spec.template.spec.containers[0].readinessProbe.httpGet.port}') != 81 ]]"; finish;;
    T03) begin "$id" "$max"; check bash -c "[[ \$(getj pod unschedulable '{.status.phase}') == Running ]]"; check bash -c "[[ -z \$(getj pod unschedulable '{.spec.nodeSelector.cka-lab\\.io/nonexistent}') ]]"; finish;;
    T04) begin "$id" "$max"; check ready_endpoint_for broken-service; check bash -c "[[ \$(getj svc broken-service '{.spec.selector.app}') == web ]]"; finish;;
    T05) begin "$id" "$max"; check evidence_has T05 'nslookup|dig|getent'; check evidence_has T05 'cluster.local|kubernetes.default'; finish;;
    T06) begin "$id" "$max"; check evidence_has T06 'logs'; check evidence_has T06 'previous|-p'; finish;;
    T07) begin "$id" "$max"; check evidence_has T07 'event|warning|failed'; check evidence_has T07 'describe'; finish;;
    T08) begin "$id" "$max"; check evidence_has T08 'cpu'; check evidence_has T08 'memory'; finish;;
    T09) begin "$id" "$max"; check evidence_has T09 'Ready|condition'; check evidence_has T09 'allocatable|capacity'; finish;;
    T10) begin "$id" "$max"; check evidence_has T10 'containerd|cri'; check evidence_has T10 'kubelet'; finish;;
    T11) begin "$id" "$max"; check evidence_has T11 'etcd'; check evidence_has T11 'apiserver|control'; finish;;
    T12) begin "$id" "$max"; check evidence_has T12 'debug|ephemeral'; check evidence_has T12 'target|process|network'; finish;;
    *) log "validator missing for $id"; return 2;;
  esac
}

if [[ "$REQUEST" == all ]]; then
  while IFS=$'\t' read -r id _; do [[ "$id" == id ]] || validate_task "$id" || exit $?; done <"$META"
else validate_task "$REQUEST" || exit $?; fi

if [[ "$FORMAT" == json ]]; then
  printf '{"namespace":"%s","earned":%d,"possible":%d,"tasks":[' "$(json_escape "$NAMESPACE")" "$EARNED" "$TOTAL"
  sep=; for r in "${RESULTS[@]}"; do IFS='|' read -r id status score max detail <<<"$r"; printf '%s{"id":"%s","status":"%s","score":%d,"max":%d,"checks":"%s"}' "$sep" "$id" "$status" "$score" "$max" "$detail"; sep=,; done
  printf ']}\n'
else
  printf '%-4s %-11s %7s %s\n' ID STATUS SCORE CHECKS
  for r in "${RESULTS[@]}"; do IFS='|' read -r id status score max detail <<<"$r"; printf '%-4s %-11s %3d/%-3d %s\n' "$id" "$status" "$score" "$max" "$detail"; done
  printf 'Score: %d/%d (SKIP/UNSUPPORTED excluded)\n' "$EARNED" "$TOTAL"
fi
[[ "$EARNED" -eq "$TOTAL" ]] && ! printf '%s\n' "${RESULTS[@]}" | grep -q '|PARTIAL|'
