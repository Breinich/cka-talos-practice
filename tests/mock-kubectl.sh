#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$MOCK_LOG"
case "$*" in
  'config current-context') echo admin@lake; exit;;
  "config view --minify"*) echo https://mock.invalid; exit;;
  cluster-info) exit;;
  'api-resources --api-group=gateway.networking.k8s.io -o name') echo httproutes.gateway.networking.k8s.io; exit;;
  'api-resources --api-group=networking.k8s.io -o name') exit;;
  'api-resources --namespaced=true --verbs=list -o name') echo configmaps; exit;;
  'get ns '*'-o jsonpath='*'cka-lab'*) case "$*" in *'prefix'*) echo cka-practice;; *) echo cka-talos-practice;; esac; exit;;
  'get pvc '*'-o name') [[ "$MOCK_MODE" == storage ]] && echo persistentvolumeclaim/data; exit 0;;
  'get pv '*'-o name') exit 0;;
  'get ns '*|'get namespace '*) exit;;
  'get configmap/lab-info '*) [[ "$MOCK_MODE" == collision ]] && { case "$*" in *jsonpath*) echo unrelated; exit;; esac; exit 0; }; exit 1;;
  'get '*'-o jsonpath='*)
    case "$*" in
      *'endpointslice '* ) [[ "$MOCK_MODE" == positive ]] && echo 'true|10.1.2.3'; exit;;
      *'job one-shot'*) [[ "$MOCK_MODE" == positive ]] && echo True; exit;;
      *'ds node-agent'*'desiredNumberScheduled'*|*'ds node-agent'*'numberReady'*) [[ "$MOCK_MODE" == positive ]] && echo 2 || echo 0; exit;;
      *'svc app-service'* ) echo ClusterIP; exit;;
      *'svc port-fixed'* ) echo http; exit;;
      *'svc broken-service'* ) echo web; exit;;
      *'get service '*'-l cka-lab.io/owner=cka-talos-practice'* ) echo web; exit;;
      *'httproute web-route'*'parentRefs'*) echo gateway1; exit;;
      *'httproute web-route'*'backendRefs'*) echo web; exit;;
      *'gateway.gateway.networking.k8s.io'* ) echo True; exit;;
    esac
    exit 1;;
  'get endpointslice '* ) [[ "$MOCK_MODE" == positive ]] && echo 'true|10.1.2.3'; exit;;
  'get ds node-agent '* ) exit;;
  'get '*'-o json')
    case "$*" in
      *'networkpolicy default-deny'*) echo '{"spec":{"policyTypes":["Ingress","Egress"],"podSelector":{}}}';;
      *'networkpolicy allow-web'*)
        [[ "$MOCK_MODE" == positive ]] && echo '{"spec":{"podSelector":{"matchLabels":{"app":"web"}},"ingress":[{"from":[{"podSelector":{"matchLabels":{"app":"client"}}}],"ports":[{"port":80}]}],"egress":[{"to":[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"kube-system"}}}],"ports":[{"port":53}]}]}}' || echo '{"spec":{"podSelector":{},"ingress":[{}],"egress":[{}]}}';;
      *'cronjob periodic'*) [[ "$MOCK_MODE" == positive ]] && echo '{"spec":{"suspend":true,"schedule":"*/5 * * * *","successfulJobsHistoryLimit":1,"failedJobsHistoryLimit":1}}' || echo '{"spec":{"suspend":false}}';;
      *'httproute web-route'*) [[ "$MOCK_MODE" == positive ]] && echo '{"metadata":{"namespace":"cka-practice"},"spec":{"parentRefs":[{"name":"gateway1"}],"rules":[{"backendRefs":[{"name":"web"}]}]},"status":{"parents":[{"parentRef":{"name":"gateway1"},"conditions":[{"type":"Accepted","status":"True"},{"type":"ResolvedRefs","status":"True"}]}]}}' || echo '{"metadata":{"namespace":"cka-practice"},"spec":{"parentRefs":[{"name":"gateway1"}],"rules":[{"backendRefs":[{"name":"web"}]}]},"status":{"parents":[]}}';;
      *'httproute.gateway.networking.k8s.io'*) echo '{"apiVersion":"v1","kind":"List","items":[{"apiVersion":"gateway.networking.k8s.io/v1","kind":"HTTPRoute","metadata":{"name":"web-route","namespace":"cka-practice","labels":{"cka-lab.io/owner":"cka-talos-practice"},"resourceVersion":"22"},"spec":{"parentRefs":[{"name":"gateway1"}]},"status":{"parents":[]}}]}';;
      *'gateway.gateway.networking.k8s.io'*) echo '{"apiVersion":"v1","kind":"List","items":[]}';;
      *) echo '{"apiVersion":"v1","kind":"List","items":[{"apiVersion":"v1","kind":"ConfigMap","metadata":{"name":"owned-existing","namespace":"cka-practice","resourceVersion":"24","labels":{"cka-lab.io/owner":"cka-talos-practice"}},"data":{"x":"1"}},{"apiVersion":"v1","kind":"ConfigMap","metadata":{"name":"unowned-existing","namespace":"cka-practice","labels":{"app":"unrelated"}},"data":{"x":"2"}}]}';;
    esac
    exit;;
  'get '*'-o name'*) exit;;
  'get ingressclass'*|'get storageclass'*|'get pods -A'* ) exit 1;;
  'get '* ) exit 1;;
  apply*) [[ "$MOCK_MODE" == restore || "$MOCK_MODE" == setup ]] || exit 1; if [[ "$*" == *"-f -"* ]]; then cat >/dev/null; fi; exit;;
  delete*) [[ "$MOCK_MODE" == restore ]] || exit 1; exit;;
  *) exit 1;;
esac
