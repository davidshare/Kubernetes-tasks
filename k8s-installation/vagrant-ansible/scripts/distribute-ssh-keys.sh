#!/bin/bash

set -e

echo "=== Setting up SSH keys for cluster access ==="

# Use the mounted Vagrant insecure keys
VAGRANT_KEY="/home/vagrant/vagrant-keys/vagrant.key.rsa"

if [ ! -f "$VAGRANT_KEY" ]; then
    echo "ERROR: Vagrant RSA key not found at $VAGRANT_KEY"
    exit 1
fi

echo "Using Vagrant key: $VAGRANT_KEY"

# Generate new SSH key pair on jumpbox
echo "Generating new SSH key pair..."
sudo -u vagrant mkdir -p /home/vagrant/.ssh
sudo -u vagrant ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N "" -q
sudo -u vagrant chmod 600 /home/vagrant/.ssh/id_rsa

# Read the public key
PUBLIC_KEY=$(sudo -u vagrant cat /home/vagrant/.ssh/id_rsa.pub)

# Distribute the public key to all nodes using Vagrant's insecure key
for IP in 192.168.56.11 192.168.56.21 192.168.56.22; do
    echo "Distributing key to $IP..."
    
    # Use Vagrant's key to SSH into each node and add our public key
    ssh -i "$VAGRANT_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$IP "
        mkdir -p /home/vagrant/.ssh
        echo '$PUBLIC_KEY' >> /home/vagrant/.ssh/authorized_keys
        chmod 700 /home/vagrant/.ssh
        chmod 600 /home/vagrant/.ssh/authorized_keys
        echo 'Key deployed to $IP'
    "
done

# Also add the key to jumpbox itself
echo "$PUBLIC_KEY" >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys

echo "=== SSH setup complete ==="
echo "New SSH key generated and distributed to all nodes"