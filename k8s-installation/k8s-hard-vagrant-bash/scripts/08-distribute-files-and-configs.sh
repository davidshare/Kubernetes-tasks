#!/bin/bash

cp kubect /usr/local/bin/kubectl

# distribute files and binaries to master notes
for instance in master01 master02; do
  scp \
    downloads/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl,etcd,etcdctl} \
    certs/{ca,kube-apiserver,service-account,etcd-server}.crt \
    certs/{ca,kube-apiserver,service-account,etcd-server}.key \
    kube-configs/{admin,kube-controller-manager,kube-scheduler}.kubeconfig \
    ../config/systemd-units/{kubeapi-server,etcd,kubelet,kube-controller-manager,kube-scheduler}.service \
    encryption-config.yaml \
    vagrant@${instance}:~/
done

# Distribute files and binaries to worker nodes
for instance in worker01 worker02; do
  scp \
    downloads/{kubelet,kube-proxy,kubectl,runc} \
    downloads/{crictl-v1.32.0-linux-amd64,containerd-2.0.2-linux-amd64}.tar.gz \
    downloads/cni-plugins-linux-arm64-v1.3.0.tgz \
    certs/{ca,${instance}}.crt \
    certs/${instance}.key \
    ../kube-configs/{kube-proxy,${instance}}.kubeconfig \
    ../kubeconfigs/{kubelet,kube-proxy}-config.yaml \
    ../config/systemd-units/{kubelet,kube-proxy,containerd}.service \
    vagrant@${instance}:~/
done


# Distribute loadbalancer config
scp config/haproxy.cfg vagrant@loadbalancer:~/