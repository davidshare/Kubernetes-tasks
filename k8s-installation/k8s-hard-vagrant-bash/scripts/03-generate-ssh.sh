#!/bin/bash

set -e  # Exit on error

source /home/vagrant/project/scripts/00-output-format.sh

SSH_DIR="/home/vagrant/.ssh"
KEY_FILE="$SSH_DIR/jumpbox_key"

# Ensure .ssh directory exists
task_echo "[Task 1] - create ssh directory if it doesn't exist and set permissions"
{
    mkdir -p $SSH_DIR
    chmod 700 $SSH_DIR
}

# Generate SSH key if not exists
task_echo "[Task 2] - generate the ssh key if it doesn't exist"
{
    if [ ! -f "$KEY_FILE" ]; then
        ssh-keygen -t rsa -b 4096 -f "$KEY_FILE" -N "" -C "jumpbox"
    fi
}

# Ensure proper permissions
task_echo "[Task 3] - change the permissions of the ssh keys"
{
    chmod 600 "$KEY_FILE"
    chmod 644 "$KEY_FILE.pub"
}

# Copy the public key to the shared folder
task_echo "[Task 4] - copy ssh keys to shared folder"
cp "$KEY_FILE.pub" /vagrant_data/jumpbox_key.pub
