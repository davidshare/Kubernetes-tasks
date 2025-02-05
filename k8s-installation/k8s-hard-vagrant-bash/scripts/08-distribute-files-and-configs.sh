#!/bin/sh

cp kubect /usr/local/bin/kubectl

# Distribute binaries to master and worker nodes
cd ./downloads/ || exit
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

for instance in master01 master02; do
  scp kube-apiserver kube-controller-manager kube-scheduler kubectl etcd etcdctl vagrant@${instance}:~/
done

cd ../

#Distribute certs to master and worker nodes
cd ./certs || exit

for instance in master01 master02; do
  scp ca.crt ca.key kube-apiserver.crt kube-apiserver.key \
    service-account.key service-account.crt etcd-server.key etcd-server.crt \
    vagrant@${instance}:~/
done

for instance in worker01 worker02; do
  scp ca.crt ${instance}.crt ${instance}.key  vagrant@${instance}:~/
done

cd ../


## Distribute kube configs
cd kube-configs || exit

for instance in worker01 worker02; do  
  scp kube-proxy.kubeconfig ${instance}.kubeconfig \
    ../kubeconfigs/kubelet-config.yaml ../kubeconfigs/kube-proxy-config.yaml vagrant@${instance}:~/  
done

for instance in master01 master02; do
  scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig vagrant@${instance}:~/
done

cd ../

# Distribute encryption keys
for instance in master01 master02; do
  scp encryption-config.yaml vagrant@${instance}:~/
done

# Distribute loadbalancer config
echo "Move haproxy config to loadbalancer instance"
scp config/haproxy.cfg vagrant@loadbalancer:~/