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
need kubectl; validate_scope
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
  else status=PARTIAL; score=$((MAX * GOOD / CHECKS)); [[ $score -eq 0 ]] && score=1
  fi
  TOTAL=$((TOTAL+MAX)); EARNED=$((EARNED+score))
  RESULTS+=("$CUR|$status|$score|$MAX|$GOOD/$CHECKS")
}
skip() { RESULTS+=("$1|$2|0|$3|0/0"); }
evidence_has() { local f="$EVIDENCE/$1.txt"; [[ -s "$f" ]] && grep -Eiq "$2" "$f"; }
getj() { kubectl get $1 $2 -n "$NAMESPACE" -o "jsonpath=$3" 2>/dev/null; }
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
    A01) begin "$id" "$max"; check evidence_has A01 'server|version'; check evidence_has A01 'api|resource'; finish;;
    A02) begin "$id" "$max"; check test -s "$EVIDENCE/A02.kubeconfig"; check kubectl --kubeconfig "$EVIDENCE/A02.kubeconfig" auth can-i get pods -n "$NAMESPACE"; finish;;
    A03) begin "$id" "$max"; check bash -c "[[ \$(getj role pod-reader '{.rules[*].resources}') == *pods* && \$(getj role pod-reader '{.rules[*].verbs}') == *get* ]]"; check bash -c "kubectl auth can-i get pods -n '$NAMESPACE' --as=system:serviceaccount:'$NAMESPACE':exam-sa | grep -qx yes"; finish;;
    A04) begin "$id" "$max"; check kubectl get sa exam-sa -n "$NAMESPACE"; check bash -c "[[ \$(getj pod sa-consumer '{.spec.serviceAccountName}') == exam-sa && \$(getj pod sa-consumer '{.spec.automountServiceAccountToken}') == false ]]"; finish;;
    A05) begin "$id" "$max"; check evidence_has A05 'yes'; check evidence_has A05 'no'; finish;;
    A06) begin "$id" "$max"; check evidence_has A06 'customresourcedefinition|crd'; check evidence_has A06 'api'; finish;;
    A07) begin "$id" "$max"; check test -s "$EVIDENCE/A07-rendered.yaml"; check grep -Eq '^kind: (Deployment|StatefulSet|DaemonSet)' "$EVIDENCE/A07-rendered.yaml"; finish;;
    A08) begin "$id" "$max"; check kubectl get deploy exam-kustom-app -n "$NAMESPACE"; check bash -c "[[ \$(getj deploy exam-kustom-app '{.spec.replicas}') == 2 ]]"; finish;;
    A09) begin "$id" "$max"; check evidence_has A09 'kube-apiserver'; check evidence_has A09 'etcd|scheduler|controller'; finish;;
    A10) begin "$id" "$max"; check evidence_has A10 'healthy|running'; check evidence_has A10 'kubelet|containerd'; finish;;
    A11) begin "$id" "$max"; check evidence_has A11 'snapshot|backup'; check evidence_has A11 'restore|quorum'; finish;;
    A14) begin "$id" "$max"; check evidence_has A14 'notafter|expire|valid'; check evidence_has A14 'certificate|cert'; finish;;
    A15) begin "$id" "$max"; check evidence_has A15 'admission|webhook'; check evidence_has A15 'pod.?security|enforce|audit|warn'; finish;;
    W01) begin "$id" "$max"; check kubectl get deploy resource-app -n "$NAMESPACE"; check bash -c "[[ -n \$(getj deploy resource-app '{.spec.template.spec.containers[0].resources.requests.cpu}') && -n \$(getj deploy resource-app '{.spec.template.spec.containers[0].resources.limits.memory}') ]]"; finish;;
    W02) begin "$id" "$max"; check bash -c "[[ \$(getj deploy rollout-app '{.spec.strategy.type}') == RollingUpdate ]]"; check bash -c "kubectl rollout status deploy/rollout-app -n '$NAMESPACE' --timeout=1s"; finish;;
    W03) begin "$id" "$max"; check bash -c "kubectl rollout history deploy/rollout-app -n '$NAMESPACE' | grep -Eq '[2-9]'"; check bash -c "kubectl rollout status deploy/rollout-app -n '$NAMESPACE' --timeout=1s"; finish;;
    W04) begin "$id" "$max"; check kubectl get job one-shot -n "$NAMESPACE"; check kubectl get cronjob periodic -n "$NAMESPACE"; finish;;
    W05) begin "$id" "$max"; check kubectl get ds node-agent -n "$NAMESPACE"; check bash -c "[[ \$(getj ds node-agent '{.status.numberReady}') == \$(getj ds node-agent '{.status.desiredNumberScheduled}') && -n \$(getj ds node-agent '{.status.numberReady}') ]]"; finish;;
    W06) begin "$id" "$max"; check bash -c "[[ \$(getj sts ordered-app '{.spec.serviceName}') == ordered-app ]]"; check bash -c "[[ \$(getj svc ordered-app '{.spec.clusterIP}') == None ]]"; finish;;
    W07) begin "$id" "$max"; check bash -c "kubectl get cm app-config -n '$NAMESPACE' >/dev/null && kubectl get secret app-secret -n '$NAMESPACE' >/dev/null"; check bash -c "v=\$(kubectl get pod config-consumer -n '$NAMESPACE' -o yaml 2>/dev/null); grep -q app-config <<<\"\$v\" && grep -q app-secret <<<\"\$v\""; finish;;
    W08) begin "$id" "$max"; check bash -c "[[ -n \$(getj deploy affinity-app '{.spec.template.spec.affinity.nodeAffinity}') ]]"; check bash -c "[[ -n \$(getj deploy affinity-app '{.spec.template.spec.affinity.podAntiAffinity}') ]]"; finish;;
    W09) begin "$id" "$max"; check bash -c "[[ -n \$(getj pod tolerant-app '{.spec.tolerations[0].key}') ]]"; check evidence_has W09 'taint|NoSchedule'; finish;;
    W10) begin "$id" "$max"; check kubectl get hpa web-hpa -n "$NAMESPACE"; check bash -c "[[ \$(getj hpa web-hpa '{.spec.maxReplicas}') -ge 2 ]]"; finish;;
    W11) begin "$id" "$max"; check bash -c "[[ -n \$(getj pod hardened-app '{.spec.containers[0].readinessProbe}') ]]"; check bash -c "[[ \$(getj pod hardened-app '{.spec.containers[0].securityContext.allowPrivilegeEscalation}') == false ]]"; finish;;
    W12) begin "$id" "$max"; check bash -c "[[ -n \$(getj pod composed-app '{.spec.initContainers[0].name}') ]]"; check bash -c "[[ \$(getj pod composed-app '{.spec.containers[*].name}') == *sidecar* ]]"; finish;;
    W13) begin "$id" "$max"; check bash -c "[[ \$(getj pdb resource-app '{.spec.minAvailable}') == 1 ]]"; check evidence_has W13 'voluntary|involuntary'; finish;;
    N01) begin "$id" "$max"; check bash -c "[[ \$(getj svc app-service '{.spec.type}') == ClusterIP ]]"; check bash -c "[[ -n \$(getj endpointslice -l kubernetes.io/service-name=app-service '{.items[0].endpoints[0].addresses[0]}') ]]"; finish;;
    N02) begin "$id" "$max"; check bash -c "[[ \$(getj svc ordered-headless '{.spec.clusterIP}') == None ]]"; check evidence_has N02 'ordered-headless'; finish;;
    N03) begin "$id" "$max"; check evidence_has N03 'endpoint|address'; check evidence_has N03 'selector|label'; finish;;
    N04) begin "$id" "$max"; check evidence_has N04 'cluster.local|svc'; check evidence_has N04 'address|name'; finish;;
    N05) begin "$id" "$max"; check kubectl get networkpolicy default-deny -n "$NAMESPACE"; check kubectl get networkpolicy allow-web -n "$NAMESPACE"; finish;;
    N06) begin "$id" "$max"; check kubectl get ingress web-ingress -n "$NAMESPACE"; check bash -c "[[ -n \$(getj ingress web-ingress '{.spec.rules[0].http.paths[0].backend.service.name}') ]]"; finish;;
    N07) begin "$id" "$max"; check kubectl get httproute web-route -n "$NAMESPACE"; check bash -c "[[ -n \$(getj httproute web-route '{.spec.parentRefs[0].name}') ]]"; finish;;
    N08) begin "$id" "$max"; check bash -c "[[ \$(getj svc port-fixed '{.spec.ports[0].targetPort}') == http ]]"; check bash -c "[[ -n \$(getj endpointslice -l kubernetes.io/service-name=port-fixed '{.items[0].endpoints[0].addresses[0]}') ]]"; finish;;
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
    T04) begin "$id" "$max"; check bash -c "[[ -n \$(getj endpointslice -l kubernetes.io/service-name=broken-service '{.items[0].endpoints[0].addresses[0]}') ]]"; check bash -c "[[ \$(getj svc broken-service '{.spec.selector.app}') == web ]]"; finish;;
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
[[ "$EARNED" -eq "$TOTAL" ]]
