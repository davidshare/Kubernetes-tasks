#!/bin/sh

create_systemd_services(){
  services=(
  "containerd" "etcd" "kube-apiserver" 
  "kube-controller-manager" "kube-proxy" 
  "kube-scheduler" "kubelet"
  )

  for service in "${services[@]}"; do
    scp "../systemd-units/&{service}.service"
      vagrant@${instance}:/etc/systemd/system/kube-apiserver.service
  done
}

    
    
enable_systemd_services() {
  sudo systemctl daemon-reload
  sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
  sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
}