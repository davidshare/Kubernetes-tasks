#!/bin/bash
set -e  # Exit on error
export KUBECONFIG=/etc/kubernetes/admin.kubeconfig

### Install Calico
{
  # 01. Install operator
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml

  # 02. Download CRDs
  curl https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml -O

  # 03. Apply CRDs
  kubectl create -f custom-resources.yaml

  # Verify Calico pods are running
  echo "Waiting for Calico pods to be ready..."
  kubectl -n kube-system wait --for=condition=ready pod -l k8s-app=calico-node --timeout=300s

  echo "Calico CNI installed successfully."
}

# Install CoreDNS
{
  echo "Installing CoreDNS..."
  kubectl apply -f configs/kubernetes-templates/coredns.yaml

  # Verify CoreDNS is running
  echo "Waiting for CoreDNS pods to be ready..."
  kubectl -n kube-system wait --for=condition=ready pod -l k8s-app=kube-dns --timeout=300s

  echo "CoreDNS installed successfully."

  # Show final status
  kubectl get pods -n kube-system
  echo "Calico and CoreDNS setup complete."
}

# 4. Check Node-to-Node Communication
echo "Testing inter-node connectivity"
kubectl run net-test --image=busybox --restart=Never -- sleep 3600
POD_IP=$(kubectl get pod net-test -o jsonpath='{.status.podIP}')
kubectl exec -it net-test -- ping -c 4 $POD_IP

