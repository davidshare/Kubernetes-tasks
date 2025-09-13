#!/bin/bash

set -e

echo "Running common provisioning tasks..."

# Disable swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Install and configure NTP
apt-get update
apt-get install -y chrony
systemctl enable chrony
systemctl start chrony

echo "Common provisioning complete."