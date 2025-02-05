#!/bin/bash

sudo sed -i '0,/RANDFILE/{s/RANDFILE/\#&/}' /etc/ssl/openssl.cnf

{
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ca-conf/ca.conf \
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
      -config "ca-conf/${i}.conf" \
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

for instance in master01 master02; do
  scp ca.crt ca.key kube-apiserver.crt kube-apiserver.key \
    service-account.key service-account.crt etcd-server.key etcd-server.crt \
    vagrant@${instance}:~/
done

for instance in worker01 worker02; do
  scp ca.crt ${instance}.crt ${instance}.key  vagrant@${instance}:~/
done
