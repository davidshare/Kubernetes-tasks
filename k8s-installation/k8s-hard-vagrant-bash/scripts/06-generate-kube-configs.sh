#!/bin/bash

set -e  # Exit on error

PROJECT_DIR='/home/vagrant/project'
source /home/vagrant/project/scripts/00-output-format.sh

LOADBALANCER_ADDRESS=192.168.56.30

task_echo "[Task 1] - add kubectl binary to path"
cp $PROJECT_DIR/cluster-files/downloads/kubectl /usr/local/bin/

cd $PROJECT_DIR/config/kubeconfigs/ || exit

task_echo "[Task 2] - Generate Kube proxy Config"
{
  kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=$PROJECT_DIR/cluster-files/certs/ca.crt \
  --embed-certs=true \
  --server=https://${LOADBALANCER_ADDRESS}:6443 \
  --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=$PROJECT_DIR/cluster-files/certs/kube-proxy.crt \
    --client-key=$PROJECT_DIR/cluster-files/certs/kube-proxy.key \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}


task_echo "[Task 3] - Generate Kube Controller manager Config"
{
  kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=$PROJECT_DIR/cluster-files/certs/ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=$PROJECT_DIR/cluster-files/certs/kube-controller-manager.crt \
    --client-key=$PROJECT_DIR/cluster-files/certs/kube-controller-manager.key \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}


task_echo "[Task 4] - Generate Kube Scheduler Config"
{
  kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=$PROJECT_DIR/cluster-files/certs/ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=$PROJECT_DIR/cluster-files/certs/kube-scheduler.crt \
    --client-key=$PROJECT_DIR/cluster-files/certs/kube-scheduler.key \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}



task_echo "[Task 5] - Generate Admin Config"
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=$PROJECT_DIR/cluster-files/certs/ca.crt \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=$PROJECT_DIR/cluster-files/certs/admin.crt \
    --client-key=$PROJECT_DIR/cluster-files/certs/admin.key \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}


task_echo "[Task 6] - Generate worker01 and worker02 Config"
{
  for host in worker01 worker02; do
    kubectl config set-cluster kubernetes-the-hard-way \
      --certificate-authority=$PROJECT_DIR/cluster-files/certs/ca.crt \
      --embed-certs=true \
      --server=https://${LOADBALANCER_ADDRESS}:6443 \
      --kubeconfig=${host}.kubeconfig

    kubectl config set-credentials system:node:${host} \
      --client-certificate=$PROJECT_DIR/cluster-files/certs/${host}.crt \
      --client-key=$PROJECT_DIR/cluster-files/certs/${host}.key \
      --embed-certs=true \
      --kubeconfig=${host}.kubeconfig

    kubectl config set-context default \
      --cluster=kubernetes-the-hard-way \
      --user=system:node:${host} \
      --kubeconfig=${host}.kubeconfig

    kubectl config use-context default --kubeconfig=${host}.kubeconfig
  done
}

cd $PROJECT_DIR || exit