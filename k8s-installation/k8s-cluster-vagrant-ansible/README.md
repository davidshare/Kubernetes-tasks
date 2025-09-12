# 5-Node Kubernetes Cluster using VirtualBox and Vagrant, Provisioned with CloudInit

## Description

This project sets up a 3-node Kubernetes cluster using Vagrant and VirtualBox. The machines are provisioned using CloudInit, and the cluster will be running Kubernetes version 1.31. The setup includes a jumpbox for administration, 1 master node, and 2 worker nodes.

## Prerequisites

For this project, we will need the following:

### Cluster setup

| Name         | Description              | CPU | RAM   | Storage | Ip            | Forwarded Port |
| ------------ | ------------------------ | --- | ----- | ------- | ------------- | -------------- |
| jumpbox      | Administration host      | 1   | 512MB | 10GB    | 192.168.56.40 | 2731           |
| master1      | Kubernetes Master node 1 | 2   | 3GB   | 20GB    | 192.168.56.11 | 2711           |
| master2      | Kubernetes Master node 2 | 2   | 3GB   | 20GB    | 192.168.56.12 | 2712           |
| master3      | Kubernetes Master node 3 | 2   | 3GB   | 20GB    | 192.168.56.13 | 2713           |
| worker1      | Kubernetes worker node 1 | 1   | 2GB   | 20GB    | 192.168.56.21 | 2721           |
| worker2      | Kubernetes worker node 2 | 1   | 2GB   | 20GB    | 192.168.56.22 | 2722           |
| loadbalancer | Kubernetes loadbalancer  | 1   | 512MB | 5GB     | 192.168.56.30 | 2732           |

#### Notes

CPU and RAM: Derived from the Vagrantfile (RESOURCES["master"]["ram"] = 3072, RESOURCES["worker"]["ram"] = 2048, LB_RAM = 512, 2 CPUs for masters, 1 CPU for workers/loadbalancer/jumpbox).
Storage: Estimated as 10GB for jumpbox (lightweight admin tasks), 20GB for masters/workers (for Kubernetes binaries, etcd, containerd), and 5GB for loadbalancer (minimal HAProxy needs). Adjustable in VirtualBox if needed.
IP Addresses: Based on IP_NW = "192.168.56." with offsets (MASTER_IP_START = 10, NODE_IP_START = 20, LB_IP_START = 30, JUMP_IP_START = 40).
Forwarded Ports: Match Vagrantfile settings (2711–2713 for masters, 2721–2722 for workers, 2731 for jumpbox, 2732 for loadbalancer).
Description: Reflects roles in your "Kubernetes the Hard Way" setup.

### Operating System

All virtual machines will run **Ubuntu 22.04 LTS**.

### Vagrant and VirtualBox Versions

Ensure you have the following versions installed:

- **Vagrant**: Version 2.2.x or higher
- **VirtualBox**: Version 6.1 or higher

### Vagrant Box Image

The base box image that will be used for all nodes is:

- **ubuntu/jammy64** (Ubuntu 22.04)
