#!/bin/bash

set -e # exit on error

source /home/vagrant/project/scripts/00-output-format.sh

SSH_DIR="/home/vagrant/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
PUB_KEY_FILE="/vagrant_data/jumpbox_key.pub"

# Ensure .ssh directory exists
task_echo "[Task 1] - Create ssh directory if it doesn't exist"
mkdir -p $SSH_DIR

task_echo "[Task 2] - set permissions for ssh directory"
chmod 700 $SSH_DIR

# Append the public key if not already added
task_echo "[Task 3] - Append public key if not already added"
if ! grep -q -f "$PUB_KEY_FILE" "$AUTHORIZED_KEYS"; then
    cat "$PUB_KEY_FILE" >> "$AUTHORIZED_KEYS"
fi

# Set correct permissions
task_echo "[Task 4] - Set correct permissions for ssh keys"
chmod 600 "$AUTHORIZED_KEYS"
chown -R vagrant:vagrant "$SSH_DIR"

echo "Jumpbox public key added to authorized_keys."
