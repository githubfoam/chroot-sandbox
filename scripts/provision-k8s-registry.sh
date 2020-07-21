#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "=============================deploy k8s registry============================================================="

kubectl apply -f kube-registry.yaml

registryPod=$(kubectl get po -n kube-system | grep kube-registry-v0 | awk '{print $1;}')

# wait for registry
kubectl wait --timeout=120s --namespace kube-system --for=condition=Ready pod/$registryPod
