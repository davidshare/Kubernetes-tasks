#!/bin/bash

source ./generate-certs.sh
source ./generate-kubeconfig.sh
source ./generate-encryption.sh
source ./setup-services.sh
source ./setup-hosts.sh

#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

install_utils(){
  echo "##### Installing basic utils #####"

  sudo apt -y update
  sudo apt-get -y install wget curl vim openssl git apt-transport-https ca-certificates
}

install_kubectl(){
  echo "##### Installing kubectl #####"

  chmod +x downloads/kubectl
  cp downloads/kubectl /usr/local/bin/
  kubectl version --client --short
  kubectl config view
}

check_component_statuses(){
  kubectl get componentstatuses --kubeconfig admin.kubeconfig
}

echo "[Jumpbox - Task 1]: Install utils]"
install_utils

echo "[Jumpbox - Task 2]: Set up hosts]"
setup_hosts

echo "[Jumpbox - Task 2]: Install kubectl]"
install_kubectl

echo "[Jumpbox - Task 3]: Generate Certs]"
generate_certs

echo "[Jumpbox - Task 4]: Distribute certificates to nodes]"
distribute_certificates

echo "[Jumpbox - Task 5]: Generate Kubeconfig files]"
LOADBALANCER_ADDRESS=192.168.56.30
generate_kube_proxy_config ${LOADBALANCER_ADDRESS}
generate_kube_controller_manager_config
generate_kube_scheduler_config
generate_admin_config

echo "[Jumpbox - Task 6]: Distribute kube configs to nodes]"
distribute_kubeconfigs

echo "[Jumpbox - Task 7]: Generate Certs]"
generate_encryption_keys

echo "[Jumpbox - Task 8]: Distribute certificates to nodes]"
distribute_encryption_keys

echo "[Jumpbox - Task 9]: Create SystemD services]"
create_systemd_services
enable_systemd_services

echo "[Jumpbox - Task 10]: Check component statuses]"
check_component_statuses

echo "[Jumpbox - Task 11]: Set up loadbalancer]"
setup_loadbalancer
verify_loadbalancer
