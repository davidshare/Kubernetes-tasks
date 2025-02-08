#!/bin/bash

set -e  # Exit on error

sudo sed -i '0,/RANDFILE/{s/RANDFILE/\#&/}' /etc/ssl/openssl.cnf

mkdir -p ./cluster-files/certs
cd ./cluster-files/certs || exit

{
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ../../config/certs-conf/ca.conf \
    -out ca.crt

  certs=(
    "admin" "worker01" "worker02" "kube-proxy" "kube-scheduler"
    "kube-controller-manager" "kube-apiserver" "service-accounts" "etcd-server"
  )

  for i in "${certs[@]}"; do
    # Generate private key
    openssl genrsa -out "${i}.key" 4096

    # Generate CSR using the corresponding configuration file
    openssl req -new -key "${i}.key" -sha256 \
      -config "../../config/certs-conf/${i}.conf" \
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