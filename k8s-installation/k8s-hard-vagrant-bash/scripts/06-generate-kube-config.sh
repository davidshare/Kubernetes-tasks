#!/bin/sh

source ./output-format.sh

LOADBALANCER_ADDRESS=192.168.56.30

display_output '[Generate Kubeconfig Task 1] - Generate Kube proxy Config'

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://${LOADBALANCER_ADDRESS}:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=kube-proxy.crt \
  --client-key=kube-proxy.key \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig


display_output '[Generate Kubeconfig Task 2] - Generate Kube Controller manager Config'

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=kube-controller-manager.crt \
  --client-key=kube-controller-manager.key \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig



display_output '[Generate Kubeconfig Task 3] - Generate Kube Scheduler Config'

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=kube-scheduler.crt \
  --client-key=kube-scheduler.key \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig



display_output '[Generate Kubeconfig Task 4] - Generate Admin Config'

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.crt \
    --client-key=admin.key \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig



display_output '[Generate Kubeconfig Task 5] - Generate worker01 Config'

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://${LOADBALANCER_ADDRESS}:6443 \
  --kubeconfig=worker01.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=worker01.crt \
  --client-key=worker01.key \
  --embed-certs=true \
  --kubeconfig=worker01.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-proxy \
  --kubeconfig=worker01.kubeconfig

kubectl config use-context default --kubeconfig=worker0.kubeconfig


display_output '[Generate Kubeconfig Task 5] - Distribute kubeconfigs'

## Distribute to worker nodes
for instance in worker01 worker02; do
  ssh vagrant@${instance} "mkdir -p /var/lib/{kube-proxy,kubelet}"
  
  scp kube-proxy.kubeconfig vagrant@${instance}:/var/lib/kube-proxy/kubeconfig
  scp ${instance}.kubeconfig root@${instance}:/var/lib/kubelet/kubeconfig 
  scp ../kubeconfigs/kubelet-config.yaml root@${instance}:/var/lib/kubelet/kubelet-config.yaml 
done

## Distribute to masters
for instance in master01 master02; do
  scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig vagrant@${instance}:~/
done


