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

task_echo "[Task 2] - Run Ansible playbook for jumpbox setup"
{
    cd /vagrant_data/ansible
    ansible-playbook -i inventory/hosts.ini playbooks/jumpbox_setup.yml
}

task_echo "[Task 3] - Run Ansible playbooks for cluster setup"
{
    cd /vagrant_data/ansible
    ansible-playbook -i inventory/hosts.ini playbooks/master.yml
}

echo "Jumpbox provisioning complete."