#!/bin/bash

set -e

echo "Running common provisioning tasks..."

# Add host entries to ALL nodes (jumpbox, masters, workers)
cat >> /etc/hosts << 'EOF'
# Kubernetes cluster nodes
192.168.56.40 jumpbox
192.168.56.11 master1
192.168.56.21 worker1
192.168.56.22 worker2
EOF

# Disable swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Install and configure NTP
apt-get update
apt-get install -y chrony curl wget git net-tools
systemctl enable chrony
systemctl start chrony

echo "Common provisioning complete."