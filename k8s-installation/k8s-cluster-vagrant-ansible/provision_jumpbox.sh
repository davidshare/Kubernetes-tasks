#!/bin/bash

set -e  # Exit on error

# Function for formatted task output
task_echo() {
    echo "===> $1"
}

task_echo "[Task 1] - Install required packages"
{
    apt-get update
    apt-get install -y ansible sshpass curl
}

task_echo "[Task 2] - Generate and distribute SSH keys"
{
    # Generate SSH keys if not present
    if [ ! -f /home/ubuntu/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -b 4096 -N "" -f /home/ubuntu/.ssh/id_rsa
        chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa*
    fi

    # Distribute SSH keys to all nodes (password: vagrant)
    for ip in 192.168.56.11 192.168.56.12 192.168.56.13 192.168.56.21 192.168.56.22 192.168.56.30; do
        sshpass -p vagrant ssh-copy-id -o StrictHostKeyChecking=no ubuntu@$ip
    done
}

task_echo "[Task 3] - Create download directories"
{
    mkdir -p /vagrant_data/ansible/roles/{certificates,etcd,control-plane,container-runtime,kubelet,kube-proxy,cni,networking}/files
    cd /vagrant_data/ansible || exit
}

task_echo "[Task 4] - Download binaries"
{
    BINARIES=(
        "https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl_1.6.5_linux_amd64|roles/certificates/files/cfssl"
        "https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssljson_1.6.5_linux_amd64|roles/certificates/files/cfssljson"
        "https://github.com/etcd-io/etcd/releases/download/v3.6.0/etcd-v3.6.0-linux-amd64.tar.gz|roles/etcd/files/etcd.tar.gz"
        "https://dl.k8s.io/v1.34.1/bin/linux/amd64/kube-apiserver|roles/control-plane/files/kube-apiserver"
        "https://dl.k8s.io/v1.34.1/bin/linux/amd64/kube-controller-manager|roles/control-plane/files/kube-controller-manager"
        "https://dl.k8s.io/v1.34.1/bin/linux/amd64/kube-scheduler|roles/control-plane/files/kube-scheduler"
        "https://dl.k8s.io/v1.34.1/bin/linux/amd64/kubelet|roles/kubelet/files/kubelet"
        "https://dl.k8s.io/v1.34.1/bin/linux/amd64/kube-proxy|roles/kube-proxy/files/kube-proxy"
        "https://github.com/opencontainers/runc/releases/download/v1.2.0/runc.amd64|roles/container-runtime/files/runc"
        "https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz|roles/container-runtime/files/containerd.tar.gz"
        "https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml|roles/cni/files/kube-flannel.yml"
        "https://dl.k8s.io/v1.34.1/bin/linux/amd64/kubectl|roles/networking/files/kubectl"
    )

    for entry in "${BINARIES[@]}"; do
        url=$(echo "$entry" | cut -d'|' -f1)
        dest=$(echo "$entry" | cut -d'|' -f2)
        filename=$(basename "$dest")

        if [ ! -f "$dest" ]; then
            echo "Downloading: $filename from $url"
            curl -L -o "$dest" "$url" --progress-bar
        else
            echo "$filename already exists. Skipping download."
        fi
    done
}

task_echo "[Task 5] - Extract binaries from archives"
{
    # Extract etcd
    if [ -f roles/etcd/files/etcd.tar.gz ]; then
        tar -xzf roles/etcd/files/etcd.tar.gz -C roles/etcd/files
        mv roles/etcd/files/etcd-v3.6.0-linux-amd64/{etcd,etcdctl} roles/etcd/files/
        rm -rf roles/etcd/files/etcd-v3.6.0-linux-amd64 roles/etcd/files/etcd.tar.gz
    fi

    # Extract containerd
    if [ -f roles/container-runtime/files/containerd.tar.gz ]; then
        tar -xzf roles/container-runtime/files/containerd.tar.gz -C roles/container-runtime/files
        mv roles/container-runtime/files/bin/containerd roles/container-runtime/files/
        rm -rf roles/container-runtime/files/bin roles/container-runtime/files/containerd.tar.gz
    fi
}

task_echo "[Task 6] - Make binaries executable"
{
    binaries=(
        "roles/certificates/files/cfssl"
        "roles/certificates/files/cfssljson"
        "roles/etcd/files/etcd"
        "roles/etcd/files/etcdctl"
        "roles/control-plane/files/kube-apiserver"
        "roles/control-plane/files/kube-controller-manager"
        "roles/control-plane/files/kube-scheduler"
        "roles/kubelet/files/kubelet"
        "roles/kube-proxy/files/kube-proxy"
        "roles/container-runtime/files/runc"
        "roles/container-runtime/files/containerd"
        "roles/networking/files/kubectl"
    )

    for binary in "${binaries[@]}"; do
        if [ -f "$binary" ]; then
            chmod +x "$binary"
        fi
    done
}

task_echo "[Task 7] - List downloaded binaries"
{
    find roles/*/files -type f -exec ls -l {} \;
}

task_echo "[Task 8] - Run Ansible playbooks"
{
    cd /vagrant_data/ansible
    for playbook in 00-prerequisites.yml 01-certificates.yml 02-etcd-cluster.yml 03-control-plane.yml \
                    04-loadbalancer.yml 05-container-runtime.yml 06-cni.yml 07-kubelet.yml \
                    08-kube-proxy.yml 09-bootstrap.yml 10-networking.yml 11-hardening.yml; do
        ansible-playbook -i inventory/hosts.ini playbooks/$playbook
    done
}

echo "Jumpbox provisioning complete."