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

task_echo "[Task 3] - Run Ansible playbook for jumpbox setup"
{
    # Check if ansible directory exists
    if [ -d "/home/vagrant/k8s-project/ansible" ]; then
        cd /home/vagrant/k8s-project/ansible
        ansible-playbook -i inventory/hosts.ini playbooks/jumpbox_setup.yml --connection=local -l jumpbox
    else
        echo "ERROR: Ansible directory not found at /home/vagrant/k8s-project/ansible/"
        echo "Available content in /home/vagrant/k8s-project/:"
        ls -la /home/vagrant/k8s-project/
        exit 1
    fi
}

echo "Jumpbox provisioning complete."