# 3-Node Kubernetes Cluster using VirtualBox and Vagrant, Provisioned with CloudInit

## Description

This project sets up a 3-node Kubernetes cluster using Vagrant and VirtualBox. The machines are provisioned using CloudInit, and the cluster will be running Kubernetes version 1.31. The setup includes a jumpbox for administration, 1 master node, and 2 worker nodes.

## Prerequisites

For this project, we will need the following:

### Virtual or Physical Machines

Our cluster will consist of 1 master and 2 worker nodes, plus a jumpbox for accessing the nodes.

| Name    | Description              | CPU | RAM   | Storage |
| ------- | ------------------------ | --- | ----- | ------- |
| jumpbox | Administration host      | 1   | 512MB | 10GB    |
| server  | Kubernetes Master node   | 1   | 2GB   | 20GB    |
| node-0  | Kubernetes worker node 1 | 1   | 2GB   | 20GB    |
| node-1  | Kubernetes worker node 2 | 1   | 2GB   | 20GB    |

### Operating System

All virtual machines will run **Ubuntu 22.04 LTS**.

### Vagrant and VirtualBox Versions

Ensure you have the following versions installed:

- **Vagrant**: Version 2.2.x or higher
- **VirtualBox**: Version 6.1 or higher

### Vagrant Box Image

The base box image that will be used for all nodes is:

- **ubuntu/jammy64** (Ubuntu 22.04)

### Provisioner

We will use **CloudInit** to automatically provision the machines. This will handle tasks such as:

- Installing dependencies (Docker, kubeadm, kubectl, and kubelet)
- Configuring networking and SSH access
- Setting up the container runtime (containerd)

### Networking

- The machines will use **private networking** (host-only or NAT) for communication.
- Each machine will have a specific static IP address assigned within the private network range.

### Tools and Dependencies

The following tools will be installed and configured on each machine:

- **Kubeadm**, **kubectl**, and **kubelet** for managing the Kubernetes cluster.
- **Container runtime**: containerd will be installed as the default runtime for Kubernetes.
- **SSH access** will be configured for connecting to the machines from the jumpbox.

### Kubernetes Version

The cluster will be running **Kubernetes 1.31**, which will be installed via `kubeadm` during the provisioning process.

---

Next: [Setting up the Jumpbox](02-jumpbox.md)
