# Kubernetes Cluster Setup with Vagrant, VirtualBox, and Ansible

## Overview

This project provisions a **7-node Kubernetes cluster** (3 masters, 2 workers, 1 load balancer, 1 jumpbox) using **Vagrant** and **VirtualBox**, with configuration managed by **Ansible**. The cluster runs **Kubernetes v1.34.1** on **Ubuntu 22.04 LTS**, using **etcd v3.6.0** for the control plane database, **containerd v2.0.0** as the container runtime, **Flannel** for networking, **HAProxy** for API server load balancing, and **CoreDNS** for cluster DNS. The setup follows a "Kubernetes the Hard Way" approach, emphasizing manual configuration for learning and production-grade deployment. A jumpbox serves as the centralized administration host, and security features like TLS certificates, RBAC, network policies, audit logging, and etcd backups ensure production readiness.

This README provides comprehensive instructions for setting up, managing, and securing the cluster, tailored for senior engineers practicing Kubernetes deployment, administration, and security.

## Cluster Architecture

The cluster consists of 4 virtual machines with the following roles and specifications:

| Name    | Role                   | CPU | RAM | Storage | IP Address    | Forwarded Port |
| ------- | ---------------------- | --- | --- | ------- | ------------- | -------------- |
| jumpbox | Administration host    | 1   | 1GB | 20GB    | 192.168.56.40 | 2731           |
| master1 | Kubernetes master node | 2   | 2GB | 50GB    | 192.168.56.11 | 2711           |
| worker1 | Kubernetes worker node | 1   | 2GB | 30GB    | 192.168.56.21 | 2721           |
| worker2 | Kubernetes worker node | 1   | 2GB | 30GB    | 192.168.56.22 | 2722           |

### Notes

- **CPU and RAM**: Defined in `Vagrantfile` (`RESOURCES["master"]["ram"] = 2048`, `RESOURCES["worker"]["ram"] = 2048`, `JUMP_RAM = 1024`). Master has 2 CPUs for control plane workloads; workers and jumpbox have 1 CPU for efficiency.
- **Storage**: 20GB for jumpbox (lightweight admin tasks), 50GB for master (etcd, Kubernetes binaries, containerd), 30GB for workers. Adjustable in VirtualBox.
- **IP Addresses**: Configured in `Vagrantfile` with `IP_NW = "192.168.56."` (master: 11, workers: 21–22, jumpbox: 40).
- **Forwarded Ports**: Enable SSH access from the host (e.g., `ssh vagrant@localhost -p 2731` for jumpbox).
- **Operating System**: All nodes run **Ubuntu 22.04 LTS** (`ubuntu/jammy64` Vagrant box).

## Prerequisites

### Software Requirements

- **Vagrant**: 2.2.x or higher
- **VirtualBox**: 6.1 or higher
- **Ansible**: 2.10 or higher (installed on jumpbox via `provision_jumpbox.sh`)
- **Git**: For cloning the repository
- **SSH Client**: For accessing nodes (e.g., `ssh vagrant@localhost -p 2731`)

### System Requirements

- **Host Machine**: Minimum 6GB RAM, 4 CPUs, 60GB free disk space to support 4 VMs.
- **Internet Access**: Required for downloading the Vagrant box (`ubuntu/jammy64`) and binaries (via `provision_jumpbox.sh`).

## Repository Structure

```
.
├── ansible
│   ├── ansible.cfg
│   ├── inventory
│   │   ├── group_vars
│   │   ├── hosts.ini
│   │   └── host_vars
│   ├── meta
│   │   └── main.yml
│   ├── playbooks
│   │   ├── 00-prerequisites.yml
│   │   ├── 01-certificates.yml
│   │   ├── 02-etcd-cluster.yml
│   │   ├── 03-control-plane.yml
│   │   ├── 04-container-runtime.yml
│   │   ├── 05-cni.yml
│   │   ├── 06-kubelet.yml
│   │   ├── 07-kube-proxy.yml
│   │   ├── 08-bootstrap.yml
│   │   ├── 09-networking.yml
│   │   ├── 10-hardening.yml
│   │   └── master.yml
│   └── roles
│       ├── bootstrap
│       ├── certificates
│       ├── cni
│       ├── common
│       ├── container-runtime
│       ├── control-plane
│       ├── etcd
│       ├── hardening
│       ├── kubelet
│       ├── kube-proxy
│       └── networking
├── ansible-tree.md
├── check_requirements.sh
├── combine.sh
├── hosts.txt
├── provision_common.sh
├── provision_jumpbox.sh
├── README.md
└── Vagrantfile

19 directories, 23 files
```

The full tree can be found here [Complete project folder structure](./ansible-tree.md)

## Setup Instructions

1. **Clone the Repository**:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Start the Cluster**:

   - Run the following command to provision all VMs (jumpbox, masters, workers, loadbalancer):
     ```bash
     vagrant up
     ```
   - Vagrant downloads the `ubuntu/jammy64` box, configures VMs per `Vagrantfile`, and runs `provision_jumpbox.sh`. The script installs Ansible, downloads binaries (Kubernetes, etcd, containerd, cfssl, Flannel manifest), and executes the `master.yml` playbook to configure the cluster.

3. **Access the Jumpbox** (Optional):

   - If you need to inspect or debug:
     ```bash
     vagrant ssh jumpbox
     ```
     Or, from the host:
     ```bash
     ssh vagrant@localhost -p 2731
     ```

4. **Manual Playbook Execution** (Optional):

   - If you prefer to run playbooks individually (e.g., for debugging), navigate to `/home/vagrant/k8s-project/ansible` on the jumpbox and execute:
     ```bash
     ansible-playbook -i inventory/hosts.ini playbooks/master.yml
     ```
     Or run specific playbooks:
     ```bash
     ansible-playbook -i inventory/hosts.ini playbooks/00-prerequisites.yml
     ansible-playbook -i inventory/hosts.ini playbooks/01-certificates.yml
     # ... continue for all playbooks
     ```

5. **Verify Cluster**:
   - From the jumpbox, check cluster status:
     ```bash
     kubectl --kubeconfig=/etc/kubernetes/admin.kubeconfig get nodes
     ```
   - Expected output: All nodes (master1, master2, master3, worker1, worker2) in `Ready` state.

## Component Configuration

- **Kubernetes**: v1.34.1, with `kube-apiserver`, `kube-controller-manager`, `kube-scheduler` on masters (192.168.56.11–13), and `kubelet`, `kube-proxy` on workers (192.168.56.21–22).
- **etcd**: v3.6.0, deployed on masters, using TLS for secure communication (ports 2379–2380/tcp).
- **Container Runtime**: containerd v2.0.0 with runc, configured with systemd cgroups for Kubernetes CRI.
- **Networking**: Flannel (VXLAN, port 8472/udp) with pod CIDR 10.244.0.0/16, CoreDNS for cluster DNS (service CIDR 10.96.0.0/12, cluster IP 10.96.0.10).
- **Load Balancer**: HAProxy on loadbalancer node (192.168.56.30:6443), balancing API server traffic to masters.
- **Certificates**: Generated with cfssl v1.6.5, stored in `/etc/kubernetes/pki/` on relevant nodes.
- **Security**:
  - TLS certificates for etcd, API server, kubelet, and admin access.
  - RBAC with restricted `cluster-admin` role (`hardening` role).
  - Default deny-all network policy for pod isolation.
  - Audit logging for API server events.
  - Daily etcd backups via cron job.
  - UFW firewall rules (ports 22/tcp, 6443/tcp, 2379–2380/tcp, 8472/udp).

## Security Features

- **TLS Certificates**: Generated by `certificates` role, securing communication for etcd, API server, kubelet, and kubectl.
- **RBAC**: Configured in `hardening` role (`rbac-config.yaml.j2`) to enforce least-privilege access.
- **Network Policies**: Default deny-all policy (`default-network-policy.yaml.j2`) in `hardening` role to restrict pod-to-pod traffic.
- **Audit Logging**: Basic audit policy (`audit-policy.yaml`) for monitoring API server events.
- **etcd Backups**: Daily snapshots via `etcd-backup.sh` in `hardening` role, stored in `/var/backups/etcd`.
- **Encryption**: API server secret encryption via `encryption-config.yaml` in `control-plane` role.
- **Firewall**: UFW rules in `common` role to restrict network access.
- **Bootstrap Security**: Bootstrap tokens created and removed post-join (`bootstrap` and `hardening` roles).

## Security Practice Recommendations

To enhance Kubernetes security practice:

- **Switch to Calico**: Replace Flannel in `cni` role for advanced network policies and encryption.
  - Update `roles/cni/files/kube-flannel.yml` to `calico.yaml`.
  - Adjust `roles/common/tasks/configure_firewall.yml` to allow BGP (179/tcp) and VXLAN (4789/udp).
- **Enhance CoreDNS**: Add DNSSEC and query logging plugins in `roles/networking/templates/coredns-deployment.yaml.j2`:
  ```yaml
  data:
    Corefile: |
      .:53 {
          errors
          health
          kubernetes cluster.local {{ pod_network_cidr | ipaddr('net') }}
          forward . /etc/resolv.conf
          cache 30
          loop
          reload
          log
          dnssec
      }
  ```
- **Add Security Tools**:
  - **Kube-bench**: Add to `hardening` role to run CIS Kubernetes Benchmark checks:
    ```yaml
    - name: Run kube-bench
      ansible.builtin.command:
        cmd: /usr/local/bin/kube-bench run --benchmark cis-1.8
      when: inventory_hostname in groups['masters']
    ```
  - **Falco**: Deploy via a manifest in `hardening` role for runtime security monitoring.
- **Simulate Attacks**: Test RBAC misconfigurations, network policy bypasses, or certificate compromises using `kubectl` or malicious pods.

## Troubleshooting

- **VM Issues**:
  - Run `vagrant status` to check VM states.
  - Use `vagrant provision` to retry provisioning if a VM fails.
  - Ensure host has sufficient resources (8GB RAM, 4 CPUs, 50GB disk).
- **Ansible Failures**:
  - Check `/var/log/ansible.log` on jumpbox for errors.
  - Verify `inventory/hosts.ini`, `group_vars/`, and `host_vars/` for correct IPs and variables.
  - Run individual playbooks for debugging:
    ```bash
    ansible-playbook -i inventory/hosts.ini playbooks/03-control-plane.yml
    ```
- **Cluster Not Ready**:
  - Verify etcd health:
    ```bash
    etcdctl --endpoints=https://192.168.56.11:2379 endpoint health
    ```
  - Check API server:
    ```bash
    curl -k https://192.168.56.30:6443/healthz
    ```
  - Inspect pod status:
    ```bash
    kubectl --kubeconfig=/etc/kubernetes/admin.kubeconfig get pods -A
    ```
- **Networking Issues**:
  - Ensure Flannel pods are running:
    ```bash
    kubectl -n kube-system get pods -l app=flannel
    ```
  - Verify firewall allows 8472/udp (`ufw status` on nodes).
- **CoreDNS Issues**:
  - Check CoreDNS pods:
    ```bash
    kubectl -n kube-system get pods -l k8s-app=kube-dns
    ```
  - Test DNS resolution:
    ```bash
    kubectl run -it --rm test --image=busybox -- nslookup kubernetes.default
    ```

## Cleanup

To destroy the cluster:

```bash
vagrant destroy -f
```

This removes all VMs and associated resources.

## Contributing

Contributions are welcome! Please submit pull requests or open issues for improvements, bug fixes, or security enhancements. Ensure changes align with the project’s goals and include clear documentation.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
