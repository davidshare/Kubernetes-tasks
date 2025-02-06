#!/bin/bash

set -e  # Exit on error

mkdir -p /var/lib/{kubelet,kubernetes/,kube-proxy/} /etc/cni/net.d/ \
  /opt/cni/bin/ /var/run/kubernetes/ /etc/containerd/ \

HOSTNAME=$(hostname -s)


### Install worker node binaries
{
  tar -xvf containerd-1.7.8-linux-arm64.tar.gz -C containerd
  tar -xvf cni-plugins-linux-arm64-v1.3.0.tgz -C /opt/cni/bin/

  rm containerd-1.7.8-linux-arm64.tar.gz cni-plugins-linux-arm64-v1.3.0.tgz

  mv containerd/bin/* /bin/
  mv kubelet kubeproxy kubectl crictl runc /usr/local/bin/
}


### Configure CNI Networking

# 01. Create the `bridge` network configuration file:
mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/

### Configure containerd
# 01. Install the `containerd` configuration files:
{
  mv containerd-config.toml /etc/containerd/config.toml
  mv containerd.service /etc/systemd/system/
}

### Configure the Kubelet
# 01.Create the `kubelet-config.yaml` configuration file:
{
  mv kubelet-config.yaml /var/lib/kubelet/
  envsubst < kubelet.service > /etc/systemd/system/kubelet.service
}

# 02. create the kubelet kubeconfig file
mv kubelet.kubeconfig /var/lib/kubelet/kubeconfig

### Configure the Kubernetes Proxy
# 01. create the kube-proxy-config.yaml file
{
  mv kube-proxy-config.yaml /var/lib/kube-proxy/
  mv kube-proxy.service /etc/systemd/system/
}

# 02. create the kube-proxy kubeconfig file
mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig


### Move worker node certificates and kubeconfigs
{
  sudo mv "${HOSTNAME}.{key,crt}" /var/lib/kubelet/
  sudo mv "${HOSTNAME}.kubeconfig" /var/lib/kubelet/kubeconfig
  sudo mv ca.crt /var/lib/kubernetes/
}

### Enable and start services
{
  sudo systemctl daemon-reload
  sudo systemctl enable kubelet kube-proxy
  sudo systemctl start kubelet kube-proxy
}

echo "[Setting up ${HOSTNAME} TASK 7] Validate service status and check logs"
{
  sudo systemctl status kubelet.service
  sudo journalctl -u kubelet.service --no-pager --output cat -f
  sudo systemctl status kube-proxy.service
  sudo journalctl -u kube-proxy.service --no-pager --output cat -f
}
