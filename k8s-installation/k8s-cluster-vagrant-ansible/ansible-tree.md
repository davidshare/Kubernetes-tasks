/ansible/
├── ansible.cfg
├── inventory/
│ ├── hosts.ini
│ └── group_vars/
│ ├── all.yml
│ ├── masters.yml
│ ├── workers.yml
│ ├── etcd.yml
│ └── loadbalancer.yml
├── host_vars/
│ ├── master1.yml
│ ├── master2.yml
│ ├── master3.yml
│ ├── worker1.yml
│ ├── worker2.yml
│ └── loadbalancer.yml
├── roles/
│ ├── common/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ ├── setup_prerequisites.yml
│ │ │ └── configure_firewall.yml
│ │ ├── handlers/
│ │ │ └── main.yml
│ │ ├── templates/
│ │ │ ├── sysctl.conf.j2
│ │ │ └── limits.conf.j2
│ ├── certificates/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ ├── download_cfssl.yml
│ │ │ ├── generate_ca.yml
│ │ │ ├── generate_admin_cert.yml
│ │ │ ├── generate_controller_certs.yml
│ │ │ ├── generate_worker_certs.yml
│ │ │ ├── generate_service_account_key.yml
│ │ │ └── copy_certs.yml
│ │ ├── files/
│ │ │ ├── ca-config.json
│ │ │ ├── ca-csr.json
│ │ │ ├── kubernetes-csr.json
│ │ │ ├── admin-csr.json
│ │ │ ├── kube-controller-manager-csr.json
│ │ │ ├── kube-scheduler-csr.json
│ │ │ ├── kubelet-csr.json
│ │ │ ├── etcd-csr.json
│ │ │ ├── service-account-csr.json
│ │ │ ├── cfssl
│ │ │ └── cfssljson
│ │ ├── handlers/
│ │ │ └── main.yml
│ ├── etcd/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ ├── download_etcd.yml
│ │ │ ├── configure.yml
│ │ │ └── service.yml
│ │ ├── templates/
│ │ │ ├── etcd.service.j2
│ │ │ └── etcd.conf.j2
│ │ ├── files/
│ │ │ ├── etcd
│ │ │ └── etcdctl
│ │ ├── handlers/
│ │ │ └── restart_etcd.yml
│ ├── control-plane/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ ├── download_control_plane_binaries.yml
│ │ │ ├── install_apiserver.yml
│ │ │ ├── install_controller_manager.yml
│ │ │ ├── install_scheduler.yml
│ │ ├── templates/
│ │ │ ├── kube-apiserver.service.j2
│ │ │ ├── kube-controller-manager.service.j2
│ │ │ ├── kube-scheduler.service.j2
│ │ │ └── encryption-config.yaml.j2
│ │ ├── files/
│ │ │ ├── kube-apiserver
│ │ │ ├── kube-controller-manager
│ │ │ └── kube-scheduler
│ │ ├── handlers/
│ │ │ ├── restart_apiserver.yml
│ │ │ ├── restart_controller_manager.yml
│ │ │ └── restart_scheduler.yml
│ ├── loadbalancer/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ └── install_haproxy.yml
│ │ ├── templates/
│ │ │ └── haproxy.cfg.j2
│ │ ├── handlers/
│ │ │ └── restart_haproxy.yml
│ ├── container-runtime/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ └── download_containerd.yml
│ │ ├── templates/
│ │ │ └── containerd-config.toml.j2
│ │ ├── files/
│ │ │ ├── containerd
│ │ │ └── runc
│ │ ├── handlers/
│ │ │ └── restart_containerd.yml
│ ├── cni/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ └── download_flannel.yml
│ │ ├── files/
│ │ │ └── kube-flannel.yml
│ │ ├── handlers/
│ │ │ └── apply_flannel.yml
│ ├── kubelet/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ ├── download_kubelet_binary.yml
│ │ │ └── configure_kubelet.yml
│ │ ├── templates/
│ │ │ ├── kubelet-config.yaml.j2
│ │ │ └── kubelet.service.j2
│ │ ├── files/
│ │ │ └── kubelet
│ │ ├── handlers/
│ │ │ └── restart_kubelet.yml
│ ├── kube-proxy/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ ├── download_kube_proxy_binary.yml
│ │ │ └── configure_kube_proxy.yml
│ │ ├── templates/
│ │ │ ├── kube-proxy-config.yaml.j2
│ │ │ └── kube-proxy.service.j2
│ │ ├── files/
│ │ │ └── kube-proxy
│ │ ├── handlers/
│ │ │ └── restart_kube_proxy.yml
│ ├── networking/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ └── deploy_coredns.yml
│ │ ├── templates/
│ │ │ └── coredns-deployment.yaml.j2
│ │ ├── files/
│ │ │ └── kubectl
│ │ ├── handlers/
│ │ │ └── apply_coredns.yml
│ ├── bootstrap/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ └── configure_bootstrap.yml
│ │ ├── handlers/
│ │ │ └── approve_csrs.yml
│ ├── hardening/
│ │ ├── defaults/
│ │ │ └── main.yml
│ │ ├── tasks/
│ │ │ ├── main.yml
│ │ │ ├── remove_bootstrap.yml
│ │ │ ├── configure_audit.yml
│ │ │ ├── network_policies.yml
│ │ │ ├── configure_rbac.yml
│ │ │ └── etcd_backup.yml
│ │ ├── handlers/
│ │ │ └── main.yml
├── playbooks/
│ ├── 00-prerequisites.yml
│ ├── 01-certificates.yml
│ ├── 02-etcd-cluster.yml
│ ├── 03-control-plane.yml
│ ├── 04-loadbalancer.yml
│ ├── 05-container-runtime.yml
│ ├── 06-cni.yml
│ ├── 07-kubelet.yml
│ ├── 08-kube-proxy.yml
│ ├── 09-bootstrap.yml
│ ├── 10-networking.yml
│ ├── 11-hardening.yml
├── Vagrantfile
├── provision_common.sh
├── provision_jumpbox.sh
