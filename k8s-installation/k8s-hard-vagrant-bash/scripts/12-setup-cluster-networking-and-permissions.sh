#!/bin/sh

# 1. Install CNI Plugins on All Nodes
mkdir -p /opt/cni/bin
curl -L -o /tmp/cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
tar -C /opt/cni/bin -xzf /tmp/cni-plugins.tgz

# 2. Install Calico CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# 3. Verify Pod Networking
kubectl get pods -n kube-system

# 4. Check Node-to-Node Communication
echo "Testing inter-node connectivity"
kubectl run net-test --image=busybox --restart=Never -- sleep 3600
POD_IP=$(kubectl get pod net-test -o jsonpath='{.status.podIP}')
kubectl exec -it net-test -- ping -c 4 $POD_IP

