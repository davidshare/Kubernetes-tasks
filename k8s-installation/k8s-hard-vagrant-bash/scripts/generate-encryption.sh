#!/bin/sh

generate_encryption_keys(){
  export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

  envsubst < config/encryption-config.yaml \
    > encryption-config.yaml
}

distribute_encryption_keys(){
  for instance in master01 master02; do
    scp encryption-config.yaml vagrant@${instance}:~/
  done
}