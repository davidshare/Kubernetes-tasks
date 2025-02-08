#!/bin/bash

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
export ENCRYPTION_KEY

envsubst < config/kubeconfigs/encryption-config.yaml > ./cluster-files/encryption-config.yaml
