#!/bin/bash

set -e  # Exit on error

# Function for formatted task output
task_echo() {
    echo "===> $1"
}

task_echo "[Task 1] - Install required packages"
{
    apt-get update
    apt-get install -y ansible
}

task_echo "[Task 2] - Verify directory structure"
{
    echo "Current directory: $(pwd)"
    echo "Listing /home/vagrant/k8s-project:"
    ls -la /home/vagrant/k8s-project/
    echo "Checking ansible directory:"
    ls -la /home/vagrant/k8s-project/ansible/ || echo "Ansible directory not found!"
}

echo "Jumpbox provisioning complete."