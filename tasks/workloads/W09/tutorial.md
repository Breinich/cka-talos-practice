# W09 Tutorial: Use taints and tolerations safely

> **Spoilers ahead.** This walkthrough is separate from the exam prompt. See [all solution tutorials](../../../SOLUTIONS.md).

## Concept and task-specific procedure

**Tolerations admit a Pod through matching taints but do not select a node.** This is offline. Read `resources/nodes.json`: oak-a has hostname `oak-a` and taint key `training.example.test/isolated`, value `yes`, effect `NoSchedule`. Write local Pod `ember-isolate` with nodeSelector `kubernetes.io/hostname: oak-a`; one busybox:1.36 container, requests 5m/8Mi, and only toleration `{key: training.example.test/isolated, operator: Equal, value: "yes", effect: NoSchedule}`. Save `${CKA_LAB_STATE_DIR:-.lab}/evidence/W09-pod.yaml`. Verify exact matching and no wildcard operator. Never apply or modify real nodes.

## Task-scoped workflow: offline artifact only

This procedure reads the task's local `resources/` and writes only local `.lab` evidence. Do not use `kubectl apply`, Helm install, or any live-resource mutation. Client-side parsing, dry-run or rendering validates syntax only; no controller status applies. Run the task scorer against the saved artifact. Synthetic CRDs, NetworkPolicies, Gateway/Ingress, hostPath/PV and component manifests remain un-applied.

## Authorization and safety boundary

For live tutorials, authorized work is limited to this task's explicitly scoped, owned resources in its unique namespace; that authorizes the exact task-directed namespace mutation, not unrelated resources. Except for a separately identified disposable environment, do not alter nodes, Talos config, `kube-system`, CRDs, cluster-scoped RBAC, webhooks, StorageClasses/PVs, etcd, or control-plane components. Offline and read-only tasks make no live mutations. Conditional SKIP means do not install optional shared infrastructure. A12/A13 are external disposable-VM exercises only.
