#!/bin/sh

cp kubect /usr/local/bin/kubectl

for instance in worker01 worker02; do
  scp \
    kubelet \
    kube-proxy \
    kubectl \
    crictl-v1.28.0-linux-arm.tar.gz \
    containerd-1.7.8-linux-arm64.tar.gz \
    cni-plugins-linux-arm64-v1.3.0.tgz \
    runc \
    vagrant@${instance}:~/
done

## Distribute to masters
for instance in master01 master02; do
  scp kube-apiserver kube-controller-manager kube-scheduler kubectl etcd etcdctl vagrant@${instance}:~/
done

echo "Move haproxy config to loadbalancer instance"
scp config/haproxy.cfg vagrant@loadbalancer:~/