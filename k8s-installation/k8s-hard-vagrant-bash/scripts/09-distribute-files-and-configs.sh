#!/bin/bash

set -e  # Exit on error
PROJECT_DIR='/home/vagrant/project'
source $PROJECT_DIR/scripts/00-output-format.sh

SSH_KEY="/home/vagrant/.ssh/jumpbox_key"
SCP_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# distribute files and binaries to master nodes
task_echo "[Task 1] - distribute files and binaries to master nodes"
for instance in master01 master02; do
  scp -i "$SSH_KEY" $SCP_OPTS \
    $PROJECT_DIR/cluster-files/downloads/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl,etcd,etcdctl} \
    $PROJECT_DIR/cluster-files/certs/{ca,kube-apiserver,service-accounts,etcd-server}.crt \
    $PROJECT_DIR/cluster-files/certs/{ca,kube-apiserver,service-accounts,etcd-server}.key \
    $PROJECT_DIR/config/kubeconfigs/{admin,kube-controller-manager,kube-scheduler}.kubeconfig \
    $PROJECT_DIR/config/systemd-units/{kube-apiserver,etcd,kubelet,kube-controller-manager,kube-scheduler}.service \
    $PROJECT_DIR/config/kubeconfigs/{encryption-config,kube-scheduler}.yaml \
    vagrant@${instance}:/home/vagrant/
done

# Distribute files and binaries to worker nodes
task_echo "[Task 2] - distribute files and binaries to worker nodes"
for instance in worker01 worker02; do
  scp -i "$SSH_KEY" $SCP_OPTS \
    $PROJECT_DIR/cluster-files/downloads/{kubelet,kube-proxy,kubectl,runc,crictl} \
    $PROJECT_DIR/cluster-files/downloads/{containerd-2.0.2-linux-amd64.tar.gz,cni-plugins-linux-amd64-v1.6.0.tgz} \
    $PROJECT_DIR/cluster-files/certs/{ca,${instance}}.crt \
    $PROJECT_DIR/cluster-files/certs/${instance}.key \
    $PROJECT_DIR/config/kubeconfigs/{kube-proxy,${instance}}.kubeconfig \
    $PROJECT_DIR/config/kubeconfigs/{kubelet,kube-proxy}-config.yaml \
    $PROJECT_DIR/config/systemd-units/{kubelet,kube-proxy,containerd}.service \
    $PROJECT_DIR/config/{10-bridge,99-loopback}.conf \
    $PROJECT_DIR/config/containerd-config.toml \
    vagrant@${instance}:/home/vagrant/
done


# Distribute loadbalancer config
task_echo "[Task 3] - Distribute loadbalancer config"
scp scp -i "$SSH_KEY" $SCP_OPTS $PROJECT_DIR/config/haproxy.cfg vagrant@loadbalancer:/home/vagrant/