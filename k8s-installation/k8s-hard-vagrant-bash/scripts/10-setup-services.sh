#!/bin/sh

services=(
  "containerd" "etcd" "kube-apiserver" 
  "kube-controller-manager" "kube-proxy" 
  "kube-scheduler" "kubelet"
)

cd ../systemd-units/ || exit

for instance in master01 master02; do
  scp "kubeapi-server.service etcd.service" vagrant@"${instance}":/
done

