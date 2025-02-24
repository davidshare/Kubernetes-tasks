#!/bin/bash

set -e  # Exit on error

PROJECT_DIR="/home/vagrant/project"

source $PROJECT_DIR/scripts/00-output-format.sh

task_echo "[Task 1] - comment out RANDFILE line in openssl conf"
sudo sed -i '0,/RANDFILE/{s/RANDFILE/\#&/}' /etc/ssl/openssl.cnf

task_echo "[Task 2] - create and navigate to certs directory"
{
  mkdir -p $PROJECT_DIR/cluster-files/certs
  cd $PROJECT_DIR/cluster-files/certs || exit
}

task_echo "[Task 3] - generate certificate authority and root certificate"
{
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config $PROJECT_DIR/config/certs-conf/ca.conf \
    -out ca.crt
}

task_echo "[Task 4] - generate certs for all components"
{
  certs=(
    "admin" "worker01" "worker02" "kube-proxy" "kube-scheduler"
    "kube-controller-manager" "kube-apiserver" "service-accounts" "etcd-server"
  )

  for i in "${certs[@]}"; do
    # Generate private key
    openssl genrsa -out "${i}.key" 4096

    # Generate CSR using the corresponding configuration file
    openssl req -new -key "${i}.key" -sha256 \
      -config "$PROJECT_DIR/config/certs-conf/${i}.conf" \
      -out "${i}.csr"
    
    # Sign the CSR using the CA
    openssl x509 -req -days 3653 -in "${i}.csr" \
      -copy_extensions copyall \
      -sha256 -CA "ca.crt" \
      -CAkey "ca.key" \
      -CAcreateserial \
      -out "${i}.crt"
  done
}

cd ~/ || exit