#!/bin/bash

set -e  # Exit on error

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
  tar -xvf etcd-v3.5.18-linux-amd64.tar.gz
  tar -xvf crictl-v1.32.0-linux-amd64.tar.gz
  mv runc.amd64 runc
  ls -al
}

rm etcd-v3.5.18-linux-amd64.tar.gz crictl-v1.32.0-linux-amd64.tar.gz

binaries=(
  kubectl kube-apiserver kube-controller-manager kube-scheduler 
  kube-proxy kubelet runc etcd etcdctl crictl
)

for binary in "${binaries[@]}"; do
  chmod +x ./"${binary}"
done

cd ../