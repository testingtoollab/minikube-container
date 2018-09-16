#!/bin/sh

source /etc/profile

echo "Starting minikube..."
minikube start --kubernetes-version=v${KUBERNETES_VERSION} --bootstrapper=localkube --vm-driver=none --memory 2048 --disk-size 8g

echo "Setting kubeconfig context..."
minikube update-context

echo "Waiting for minkube to be ready..."
set +e
j=0
while [ $j -le 150 ]; do
    kubectl get po &> /dev/null
    if [ $? -ne 1 ]; then
        break
    fi
    sleep 2
    j=$(( j + 1 ))
done
set -e

if [[ -d "/kube_specs" ]]; then
    echo "Apply kubernetes specs..."
    kubectl apply -R -f /kube_specs/
fi

echo "Minikube is ready."

exec "$@"
