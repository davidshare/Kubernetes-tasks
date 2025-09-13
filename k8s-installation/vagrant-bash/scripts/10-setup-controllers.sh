#!/bin/bash

set -e  # Exit on error

source /home/vagrant/project/scripts/00-output-format.sh

# Disable interactive prompts
export DEBIAN_FRONTEND=noninteractive

task_echo "[Task 1] - Get ip addresses and host names"
INTERNAL_IP=$(ip addr show enp0s8 | grep "inet " | awk '{print $2}' | cut -d / -f 1)
ETCD_NAME=$(hostname -s)
HOSTNAME=$(hostname -s)

export INTERNAL_IP
export ETCD_NAME

task_echo "[Task 2] - create kubernetes, and etcd directories"
mkdir -p /var/lib/kubernetes /var/lib/etcd/ /etc/etcd/ /etc/kubernetes/config

task_echo "[Task 3] - Set permissions for etcd directory"
chmod 700 /var/lib/etcd

# Install controller binaries
task_echo "[Task 4] - install kubernetes master binaries"
mv kube-apiserver kube-controller-manager kube-scheduler kubectl etcd etcdctl /usr/local/bin


### Configure apiserver
task_echo "[Task 5] - configure apiserver: move certs and encryption file"
cp ca.{key,crt} /var/lib/kubernetes/
mv {kube-apiserver,service-accounts}.crt \
  {kube-apiserver,service-accounts}.key \
  encryption-config.yaml \
  /var/lib/kubernetes/

task_echo "[Task 6] - configure apiserver: create systemd service file"
envsubst < kube-apiserver.service > /etc/systemd/system/kube-apiserver.service


### Configure the Kubernetes Controller Manager
task_echo "[Task 7] - configure controller manager: setup kubeconfig"
mv kube-controller-manager.kubeconfig /var/lib/kubernetes/

task_echo "[Task 8] - configure controller manager: setup systemd service"
mv kube-controller-manager.service /etc/systemd/system/


### Configure the Kubernetes Scheduler
task_echo "[Task 9] - configure scheduler: setup kubeconfig"
mv kube-scheduler.kubeconfig /var/lib/kubernetes/

task_echo "[Task 10] - configure scheduler: setup config"
mv kube-scheduler.yaml /etc/kubernetes/config/

task_echo "[Task 11] - configure scheduler: setup service"
mv kube-scheduler.service /etc/systemd/system/


### Bootstrap etcd
task_echo "[Task 12] - Bootstrap etcd: setup certs"
cp ca.crt /etc/etcd/
mv etcd-server.crt etcd-server.key /etc/etcd

task_echo "[Task 13] - Bootstrap etcd: setup service"
envsubst < etcd.service > /etc/systemd/system/etcd.service

task_echo "[Task 14] - enable and start controller components"
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler etcd
sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler

sleep 30

task_echo "[Task 13] - check etcd"
echo "[Setting up ${HOSTNAME} TASK 7] - Confirm ETCD Status"
sudo systemctl status etcd.service || true
