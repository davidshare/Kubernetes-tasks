#!/bin/bash

set -e  # Exit on error

echo "=================================== Create download directory ================================"
mkdir -p downloads
cd downloads || exit

echo "=================================== Downloading binaries ================================"

BINARIES=(
  "https://dl.k8s.io/v1.32.1/bin/linux/amd64/kubectl"
  "https://dl.k8s.io/v1.32.1/bin/linux/amd64/kube-apiserver"
  "https://dl.k8s.io/v1.32.1/bin/linux/amd64/kube-controller-manager"
  "https://dl.k8s.io/v1.32.1/bin/linux/amd64/kube-scheduler"
  "https://dl.k8s.io/v1.32.1/bin/linux/amd64/kube-proxy"
  "https://dl.k8s.io/v1.32.1/bin/linux/amd64/kubelet"
  "https://github.com/opencontainers/runc/releases/download/v1.2.4/runc.amd64"
  "https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.32.0/crictl-v1.32.0-linux-amd64.tar.gz"
  "https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.0.tgz"
  "https://github.com/containerd/containerd/releases/download/v2.0.2/containerd-2.0.2-linux-amd64.tar.gz"
  "https://github.com/etcd-io/etcd/releases/download/v3.5.18/etcd-v3.5.18-linux-amd64.tar.gz"
)

for binary_url in "${BINARIES[@]}"; do
  filename=$(basename "$binary_url")

  if [ ! -f "$filename" ]; then
    echo "Downloading: $filename from $binary_url"
    curl -L -o "$filename" "$binary_url" --progress-bar
  else
    echo "$filename already exists. Skipping download."
  fi
done


echo "=================================== List downloaded binaries ================================"
ls -al

echo "=================================== extract files ================================"
{
  tar -xvf etcd-v3.5.18-linux-amd64.tar.gz
  mv etcd-v3.5.18-linux-amd64/{etcd,etcdctl,etcdutl} .
  tar -xvf crictl-v1.32.0-linux-amd64.tar.gz
  mv runc.amd64 runc
  ls -al
}

echo "=================================== make binaries executable ================================"
binaries=(
  kubectl kube-apiserver kube-controller-manager kube-scheduler 
  kube-proxy kubelet runc etcd etcdctl etcdutl crictl 
)

for binary in "${binaries[@]}"; do
  chmod +x ./"${binary}"
done

# echo "=================================== before cleanup files ================================"
# ls -al
# rm -rf etcd-v3.5.18-linux-amd64.tar.gz crictl-v1.32.0-linux-amd64.tar.gz etcd-v3.5.18-linux-amd64

# echo "=================================== after cleanup files ================================"
# ls -al

cd ../