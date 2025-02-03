#!/bin/bash

download_binaries() {
  # Create binaries directory
  mkdir -p ../binaries
  cd ../binaries

  # Download Kubernetes binaries
  wget -q --show-progress --https-only --timestamping \
    "https://storage.googleapis.com/kubernetes-release/release/v1.32.1/bin/linux/amd64/kube-apiserver" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.32.1/bin/linux/amd64/kube-controller-manager" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.32.1/bin/linux/amd64/kube-scheduler" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.32.1/bin/linux/amd64/kubectl" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.32.1/bin/linux/amd64/kubelet" \
    "https://storage.googleapis.com/kubernetes-release/release/v1.32.1/bin/linux/amd64/kube-proxy" \
    "https://github.com/etcd-io/etcd/releases/download/v3.5.1/etcd-v3.5.1-linux-amd64.tar.gz"

  # Extract etcd binaries
  tar -xvf etcd-v3.5.1-linux-amd64.tar.gz
  rm -rf etcd-v3.5.1-linux-amd64.tar.gz etcd-v3.5.1-linux-amd64

  # Make binaries executable
  chmod +x *
}

distribute_binaries(){
  for instance in worker01 worker02; do
    scp kubelet kube-proxy vagrant@${instance}:/usr/local/bin/
  done

  ## Distribute to masters
  for instance in master01 master02; do
    scp kube-apiserver kube-controller-manager kube-scheduler kubectl etcd etcdctl vagrant@${instance}:/usr/local/bin/
  done

}
