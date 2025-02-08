#!/bin/bash

set -e # exit on error

source ./00-output-format.sh

task_echo "[Task 1] - create neccessary directories for binaries and plugins"
mkdir -p /var/lib/{kubelet,kubernetes/,kube-proxy/} /etc/cni/net.d/ \
  /opt/cni/bin/ /var/run/kubernetes/ /etc/containerd/ \

HOSTNAME=$(hostname -s)


### Install worker node binaries
task_echo "[Task 2] - setup ${HOSTNAME} binaries"
{
  tar -xvf containerd-1.7.8-linux-arm64.tar.gz -C containerd
  tar -xvf cni-plugins-linux-arm64-v1.3.0.tgz -C /opt/cni/bin/

  rm containerd-1.7.8-linux-arm64.tar.gz cni-plugins-linux-arm64-v1.3.0.tgz

  mv containerd/bin/* /bin/
  mv kubelet kubeproxy kubectl crictl runc /usr/local/bin/
}


### Configure CNI Networking
task_echo "[Task 3] - Create the bridge network configuration file"
mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/

### Configure containerd
task_echo "[Task 4] - Install the containerd configuration files"
{
  mv containerd-config.toml /etc/containerd/config.toml
  mv containerd.service /etc/systemd/system/
}

### Configure the Kubelet
task_echo "[Task 5] - Create the kubelet-config.yaml configuration file"
{
  mv kubelet-config.yaml /var/lib/kubelet/
  envsubst < kubelet.service > /etc/systemd/system/kubelet.service
}

task_echo "[Task 6] - create the kubelet kubeconfig file"
mv kubelet.kubeconfig /var/lib/kubelet/kubeconfig

### Configure the Kubernetes Proxy
task_echo "[Task 7] - create the kube-proxy-config.yaml file"
{
  mv kube-proxy-config.yaml /var/lib/kube-proxy/
  mv kube-proxy.service /etc/systemd/system/
}

task_echo "[Task 8] - create the kube-proxy kubeconfig file"
mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig


task_echo "[Task 9] - Move worker node certificates and kubeconfigse"
{
  sudo mv "${HOSTNAME}.{key,crt}" /var/lib/kubelet/
  sudo mv "${HOSTNAME}.kubeconfig" /var/lib/kubelet/kubeconfig
  sudo mv ca.crt /var/lib/kubernetes/
}

### Enable and start services
task_echo "[Task 10] - Enable and start services"
{
  sudo systemctl daemon-reload
  sudo systemctl enable kubelet kube-proxy
  sudo systemctl start kubelet kube-proxy
}

task_echo "[Task 11] - Validate service status and check logs"
{
  sudo systemctl status kubelet.service
  sudo journalctl -u kubelet.service --no-pager --output cat -f
  sudo systemctl status kube-proxy.service
  sudo journalctl -u kube-proxy.service --no-pager --output cat -f
}
