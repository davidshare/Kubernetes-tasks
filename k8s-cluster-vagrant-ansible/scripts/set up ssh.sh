#!/bin/bash

# # Read hosts from the file
# hosts=$(grep -v "192.168.56.40" hosts.txt | tr -d '\n')

# # Specify the fixed key file name
# KEY_NAME="id_rsa"

# # Check if the key exists
# if [ ! -f "${HOME}/.ssh/${KEY_NAME}" ]; then
#     # Generate the key without passphrase
#     ssh-keygen -t rsa -b 4096 -C "davidessienshare@gmail.com" -f "${HOME}/.ssh/${KEY_NAME}" -N ""
# else
#     echo "Using existing SSH key: ${HOME}/.ssh/${KEY_NAME}"
# fi


# # Copy SSH key to all VMs excluding jumpbox
# for host in $hosts; do
#   ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $host
# done

# # Test SSH connection
# for host in $hosts; do
#   ssh $host "echo 'SSH works'"
# done

# # Configure SSH config file for all VMs excluding jumpbox
# for host in $hosts; do
#   ssh $host "mkdir -p ~/.ssh && echo \"Host $host\" > ~/.ssh/config && echo \"    HostName $(hostname -f)\" >> ~/.ssh/config && echo \"    User ubuntu\" >> ~/.ssh/config"
# done

# # Set up passwordless sudo
# for host in $hosts; do
#   ssh $host "mkdir -p ~/.ssh && chmod 0700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys && echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/ubuntu"
# done

# Declare arrays to hold IP addresses and hostnames
declare -a ips
declare -a hosts

# Read hosts and IPs from the file (excluding the jumpbox)
while IFS=" " read -r ip host; do
  if [[ "$ip" != "192.168.56.40" ]]; then
    ips+=("$ip")
    hosts+=("$host")
  fi
done < hosts.txt

# Specify the fixed key file name
KEY_NAME="id_rsa"

# Check if the key exists
if [ ! -f "${HOME}/.ssh/${KEY_NAME}" ]; then
    # Generate the key without passphrase
    ssh-keygen -t rsa -b 4096 -C "davidessienshare@gmail.com" -f "${HOME}/.ssh/${KEY_NAME}" -N ""
else
    echo "Using existing SSH key: ${HOME}/.ssh/${KEY_NAME}"
fi

# Copy SSH key to all VMs excluding jumpbox
for ((i=0; i<${#hosts[@]}; i++)); do
  ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no "${hosts[$i]}"
done

# Test SSH connection
for ((i=0; i<${#hosts[@]}; i++)); do
  ssh "${hosts[$i]}" "echo 'SSH works'"
done

# Configure SSH config file for all VMs excluding jumpbox
for ((i=0; i<${#hosts[@]}; i++)); do
  ssh "${hosts[$i]}" "mkdir -p ~/.ssh && echo \"Host ${hosts[$i]}\" > ~/.ssh/config && echo \"    HostName ${ips[$i]}\" >> ~/.ssh/config && echo \"    User vagrant\" >> ~/.ssh/config"
done

# Set up passwordless sudo
for ((i=0; i<${#hosts[@]}; i++)); do
  ssh "${hosts[$i]}" "mkdir -p ~/.ssh && chmod 0700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys && echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vagrant"
done
