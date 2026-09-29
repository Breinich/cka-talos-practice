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
# Task wrappers supply a verified, independently scoped state directory.
META="$ROOT/metadata/tasks.tsv"; EVIDENCE="$STATE_DIR/evidence"
CAP="$STATE_DIR/capabilities.env"
METRICS=false; NETWORKPOLICY=false; INGRESS=false; GATEWAY=false; STORAGECLASS=false; EXPANDABLE=false; HELM=false; TALOSCTL=false; DEBUG=false
[[ -r "$CAP" ]] && source "$CAP"
export CKA_LAB_STORAGE_CLASS="${CKA_LAB_STORAGE_CLASS:-}"

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
    conditional:debug) [[ "$DEBUG" == true ]] || { skip "$id" SKIP "$max"; return; };;
    conditional:networkpolicy) [[ "$NETWORKPOLICY" == true ]] || { skip "$id" SKIP "$max"; return; };;
    conditional:ingress) [[ "$INGRESS" == true ]] || { skip "$id" SKIP "$max"; return; };;
    conditional:gateway) [[ "$GATEWAY" == true ]] || { skip "$id" SKIP "$max"; return; };;
    conditional:storageclass) [[ "$STORAGECLASS" == true ]] || { skip "$id" SKIP "$max"; return; };;
    conditional:expandable) [[ "$EXPANDABLE" == true ]] || { skip "$id" SKIP "$max"; return; };;
    simulation:helm) [[ "$HELM" == true ]] || { skip "$id" UNSUPPORTED "$max"; return; };;
  esac
  # Worker-only placement is not exercisable on clusters without enough untainted,
  # Ready workers; report SKIP rather than awarding credit for Pending Pods.
  if [[ "$id" == W05 || "$id" == W08 ]]; then
    eligible="$(kubectl get nodes -l node-role.kubernetes.io/worker -o json 2>/dev/null | python3 "$ROOT/scripts/check_workloads.py" workers "$([[ "$id" == W05 ]] && echo 1 || echo 2)" 2>/dev/null || true)"
    if [[ "$id" == W05 && "${eligible:-0}" -lt 1 || "$id" == W08 && "${eligible:-0}" -lt 2 ]]; then skip "$id" SKIP "$max"; return; fi
  fi
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
    W01) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W02) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W03) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W04) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W05) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W06) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W07) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W08) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W09) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W10) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W11) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W12) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    W13) begin "$id" "$max"; check python3 "$ROOT/scripts/check_workloads.py" "$id" 1; check python3 "$ROOT/scripts/check_workloads.py" "$id" 2; finish;;
    N01|N02|N03|N04|N05|N06|N07|N08|N09|N10|N11)
      begin "$id" "$max"
      check python3 "$ROOT/scripts/check_networking.py" "$id" 1
      check python3 "$ROOT/scripts/check_networking.py" "$id" 2
      finish;;
    S01|S02|S03|S04|S05|S06)
      begin "$id" "$max"
      check python3 "$ROOT/scripts/check_storage.py" "$id" 1
      check python3 "$ROOT/scripts/check_storage.py" "$id" 2
      finish;;
    T01|T02|T03|T04|T05|T06|T07|T08|T09|T10|T11|T12)
      begin "$id" "$max"
      check python3 "$ROOT/scripts/check_troubleshooting.py" "$id" 1
      check python3 "$ROOT/scripts/check_troubleshooting.py" "$id" 2
      finish;;
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
