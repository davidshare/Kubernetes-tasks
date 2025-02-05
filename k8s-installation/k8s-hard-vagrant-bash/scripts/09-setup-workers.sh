#!/bin/sh

mkdir -p /var/lib/kubelet /var/lib/kubernetes /var/lib/kube-proxy \
  /etc/cni/net.d /opt/cni/bin /var/run/kubernetes

HOSTNAME=$(hostname -s)


echo "[Setting up ${HOSTNAME} TASK 1] - Move binaries to their respective directories"
mv kubelet kubeproxy kubectl /usr/local/bin

echo "[Setting up ${HOSTNAME} TASK 2] - Move certificates to their respective directories"
{
  mv "${HOSTNAME}.{crt,key}" /var/lib/kubelet
  mv ca.crt /var/lib/kubernetes
}

echo "[Setting up ${HOSTNAME} TASK 3] - Move kubeconfigs to their respective directories"
{
  cp kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
  cp "${HOSTNAME}.kubeconfig" /var/lib/kubelet/kubeconfig 
  cp kubeconfigs/kubelet-config.yaml /var/lib/kubelet/kubelet-config.yaml 
  cp kubeconfigs/kube-proxy-config.yaml /var/lib/kube-proxy/kube-proxy-config.yaml
}

echo "[Setting up ${HOSTNAME} TASK 4] - Copy config files"
{
  mv kubelet-config.yaml /var/lib/kubelet/
  mv kube-proxy-config.yaml /var/lib/kube-proxy/
}

echo "[Setting up ${HOSTNAME} TASK 5] - Setup services"
{
  envsubst < kubelet.service > /etc/systemd/system/kubelet.service
  mv kube-proxy.service /etc/systemd/system/kube-proxy.service
}

echo "[Setting up ${HOSTNAME} TASK 6] - Enable and start services"
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
