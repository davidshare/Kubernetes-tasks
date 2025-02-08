#!/bin/bash

set -e #exit on error

source ./00-output-format.sh

task_echo "[Task 1] - Generate encryption key"
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
export ENCRYPTION_KEY

task_echo "[Task 2] - Generate encryption config file"
envsubst < config/kubeconfigs/encryption-config.yaml > ./cluster-files/encryption-config.yaml
