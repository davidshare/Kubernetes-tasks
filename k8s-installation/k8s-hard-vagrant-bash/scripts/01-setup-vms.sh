#!/bin/bash

set -e  # Exit on error

source ./00-output-format.sh

# Disable interactive prompts
export DEBIAN_FRONTEND=noninteractive

task_echo "[TASK 1] Show whoami"
whoami

task_echo "[TASK 2] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

task_echo "[TASK 3] Letting iptables see bridged traffic"
modprobe br_netfilter

task_echo "[TASK 4] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/k8s.conf<<EOF
br_netfilter
EOF

task_echo "[TASK 5] Add Kernel settings"
cat >>/etc/sysctl.d/k8s.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

task_echo "[TASK 6] Install needed packages"
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    gettext-base \
    wget \
    tar \
    socat \
    conntrack \
    ipset \
    iptables \
    jq


task_echo "[TASK 7] Disable swap"
swapoff -a
sed -i '/swap/d' /etc/fstab

task_echo "[TASK 8] Update DNS"
sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf
service systemd-resolved restart