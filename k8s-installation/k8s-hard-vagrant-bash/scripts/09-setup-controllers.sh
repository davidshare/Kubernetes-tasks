#!/bin/bash

set -e  # Exit on error

# Disable interactive prompts
export DEBIAN_FRONTEND=noninteractive


INTERNAL_IP=$(ip addr show enp0s8 | grep "inet " | awk '{print $2}' | cut -d / -f 1)
ETCD_NAME=$(hostname -s)
HOSTNAME=$(hostname -s)


export INTERNAL_IP
export ETCD_NAME

mkdir -p /var/lib/kubernetes /etc/etcd/ /var/lib/etcd/
chmod 700 /var/lib/etcd

# Install controller binaries
mv kube-apiserver kube-controller-manager kube-scheduler kubectl etcd etcdctl /usr/local/bin


### Configure apiserver
# 01. Copy certificates
mv {ca,kube-api-server,service-accounts}.crt \
  {ca,kube-api-server,service-accounts}.key \
  encryption-config.yaml \
  /var/lib/kubernetes/

#02. Create systemd service
envsubst < kube-apiserver.service > /etc/systemd/system/kube-apiserver.service


### Configure the Kubernetes Controller Manager
# 01. Move the `kube-controller-manager` kubeconfig into place:
mv kube-controller-manager.kubeconfig /var/lib/kubernetes/

# 02. Create the `kube-controller-manager.service` systemd unit file:
mv kube-controller-manager.service /etc/systemd/system/


### Configure the Kubernetes Scheduler
# 01. Move the `kube-scheduler` kubeconfig into place:
mv kube-scheduler.kubeconfig /var/lib/kubernetes/

# 02. Create the `kube-scheduler.yaml` configuration file:
mv kube-scheduler.yaml /etc/kubernetes/config/

# 03. Create the `kube-scheduler.service` systemd unit file:
mv kube-scheduler.service /etc/systemd/system/


### Bootstrap etcd
# 0.1 Copy etcd certs
cp ca.crt /etc/etcd/
mv etcd-server.crt etcd-server.key /etc/etcd

#02. Create etcd systemd service
envsubst < etcd.service > /etc/systemd/system/etcd.service

## Enable and start all services"
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler etcd
sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler etcd

sleep 30

echo "[Setting up ${HOSTNAME} TASK 7] - Confirm ETCD Status"
sudo systemctl status etcd.service
sudo journalctl -u etcd.service --no-pager --output cat -f
etcdctl member list
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/etcd-server.crt \
  --key=/etc/etcd/etcd-server.key
