#!/bin/sh

# Disable interactive prompts
export DEBIAN_FRONTEND=noninteractive


INTERNAL_IP=$(ip addr show enp0s8 | grep "inet " | awk '{print $2}' | cut -d / -f 1)
ETCD_NAME=$(hostname -s)
HOSTNAME=$(hostname -s)


export INTERNAL_IP
export ETCD_NAME

mkdir /var/lib/kubernetes

echo "[Setting up ${HOSTNAME} TASK 1] - Move binaries to their respective directories"
mv kube-apiserver kube-controller-manager kube-scheduler kubectl etcd etcdctl /usr/local/bin

echo "[Setting up ${HOSTNAME} TASK 2] - Move certs to their respective directories"
mkdir -p /var/lib/kubernetes/ /etc/etcd/ /var/lib/etcd/

cp ca.crt /etc/etcd/
mv etcd-server.crt etcd-server.key /etc/etcd

mv ca.crt ca.key kube-apiserver.crt kube-apiserver.key \
  service-account.crt service-account.key /var/lib/kubernetes

echo "[Setting up ${HOSTNAME} TASK 3] - Move kubeconfigs to their respective directories"
mv admin.kubeconfig kube-controller-manager.kubeconfig \
  kube-scheduler.kubeconfig /var/lib/kubernetes

echo "[Setting up ${HOSTNAME} TASK 4] - Copy encryption key"
mv encryption-config.yaml /var/lib/kubernetes


echo "[Setting up ${HOSTNAME} TASK 5] - Setup services"
envsubst < etcd.service > /etc/systemd/system/etcd.service
envsubst < kube-apiserver.service > /etc/systemd/system/kube-apiserver.service
mv kube-controller-manager.service kube-scheduler.service /etc/systemd/system/

echo "[Setting up ${HOSTNAME} TASK 6] - Enable and start all services"
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler etcd
sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler etcd


echo "[Setting up ${HOSTNAME} TASK 7] - Confirm ETCD Status"
sudo systemctl status etcd.service
sudo journalctl -u etcd.service --no-pager --output cat -f
etcdctl member list
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/etcd-server.crt \
  --key=/etc/etcd/etcd-server.key

echo "[Setting up ${HOSTNAME} TASK 8] - Validate Kubernetes Component Status"
kubectl get componentstatuses --kubeconfig admin.kubeconfig