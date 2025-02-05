#!/bin/sh

export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

envsubst < config/encryption-config.yaml \
  > encryption-config.yaml
