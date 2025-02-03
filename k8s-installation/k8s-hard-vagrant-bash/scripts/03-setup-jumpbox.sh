#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "##### Installing basic utils #####"
sudo apt -y update
sudo apt-get -y install wget curl vim openssl git apt-transport-https ca-certificates

echo "##### Installing kubectl #####"
chmod +x downloads/kubectl
cp downloads/kubectl /usr/local/bin/
kubectl version --client --short
kubectl config view

echo "##### Installing kubectl #####"
kubectl get componentstatuses --kubeconfig admin.kubeconfig
