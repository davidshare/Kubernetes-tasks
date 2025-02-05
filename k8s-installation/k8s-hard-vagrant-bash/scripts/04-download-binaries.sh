#!/bin/bash

mkdir -p downloads
cd downloads || exit

wget -q --show-progress --https-only --timestamping \
  "https://dl.k8s.io/v1.32.1/bin/linux/amd64/kubectl" \
  "https://dl.k8s.io/v1.32.0/bin/linux/amd64/kube-apiserver" \
  "https://dl.k8s.io/v1.32.0/bin/linux/amd64/kube-controller-manager" \
  "https://dl.k8s.io/v1.32.0/bin/linux/amd64/kube-scheduler" \
  "https://dl.k8s.io/v1.32.0/bin/linux/amd64/kube-proxy" \
  "https://dl.k8s.io/v1.32.0/bin/linux/amd64/kubelet" \
  "https://github.com/opencontainers/runc/releases/download/v1.2.4/runc.amd64" \
  "https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.32.0/crictl-v1.32.0-linux-amd64.tar.gz" \
  "https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.0.tgz" \
  "https://github.com/containerd/containerd/releases/download/v2.0.2/containerd-2.0.2-linux-amd64.tar.gz" \
  "https://github.com/etcd-io/etcd/releases/download/v3.5.18/etcd-v3.5.18-linux-amd64.tar.gz"

{
  mkdir -p containerd cni
  tar -xvf crictl-v1.28.0-linux-arm.tar.gz
  tar -xvf containerd-1.7.8-linux-arm64.tar.gz -C containerd
  tar -xvf etcd-v3.5.18-linux-amd64.tar.gz
  tar -xvf cni-plugins-linux-arm64-v1.3.0.tgz -C cni
  mv runc.arm64 runc

  ls -al
}

rm -rf ./*.gx ././*.tgz etcd-v3.5.18-linux-amd64
chmod +x ./*

for instance in worker01 worker02; do
  scp kubelet kube-proxy kubectl vagrant@${instance}:~/
done

## Distribute to masters
for instance in master01 master02; do
  scp kube-apiserver kube-controller-manager kube-scheduler kubectl etcd etcdctl vagrant@${instance}:~/
done

cp kubect /usr/local/bin/kubectl

echo "Move haproxy config to loadbalancer instance"
scp config/haproxy.cfg vagrant@loadbalancer:~/

cd ../