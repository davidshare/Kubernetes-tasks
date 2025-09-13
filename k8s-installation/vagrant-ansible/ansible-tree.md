# Project directory structure

```
.
├── ansible
│   ├── ansible.cfg
│   ├── inventory
│   │   ├── group_vars
│   │   │   ├── all.yml
│   │   │   ├── etcd.yml
│   │   │   ├── masters.yml
│   │   │   ├── network.yml
│   │   │   └── workers.yml
│   │   ├── hosts.ini
│   │   └── host_vars
│   │       ├── master1.yml
│   │       ├── worker1.yml
│   │       └── worker2.yml
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
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── approve_csrs.yml
│       │   ├── tasks
│       │   │   ├── configure_bootstrap.yml
│       │   │   ├── generate_kubeconfigs.yml
│       │   │   └── main.yml
│       │   └── templates
│       │       ├── admin.kubeconfig.j2
│       │       ├── bootstrap.kubeconfig.j2
│       │       ├── kubelet.kubeconfig.j2
│       │       └── kube-proxy.kubeconfig.j2
│       ├── certificates
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── main.yml
│       │   └── tasks
│       │       ├── copy_certs.yml
│       │       ├── generate_admin_cert.yml
│       │       ├── generate_ca.yml
│       │       ├── generate_controller_certs.yml
│       │       ├── generate_serviceaccount_key.yml
│       │       ├── generate_worker_certs.yml
│       │       └── main.yml
│       ├── cni
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── apply_flannel.yml
│       │   └── tasks
│       │       ├── configure_flannel.yml
│       │       └── main.yml
│       ├── common
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   ├── configure_firewall.yml
│       │   │   ├── main.yml
│       │   │   └── setup_prerequisites.yml
│       │   └── templates
│       │       ├── limits.conf.j2
│       │       └── sysctl.conf.j2
│       ├── container-runtime
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── restart_containerd.yml
│       │   ├── tasks
│       │   │   ├── configure_containerd.yml
│       │   │   └── main.yml
│       │   └── templates
│       │       └── containerd-config.toml.j2
│       ├── control-plane
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   ├── restart_apiserver.yml
│       │   │   ├── restart_controller_manager.yml
│       │   │   └── restart_scheduler.yml
│       │   ├── tasks
│       │   │   ├── install_apiserver.yml
│       │   │   ├── install_controller_manager.yml
│       │   │   ├── install_scheduler.yml
│       │   │   └── main.yml
│       │   └── templates
│       │       ├── encryption-config.yaml.j2
│       │       ├── kube-apiserver.service.j2
│       │       ├── kube-apiserver.yaml.j2
│       │       ├── kube-controller-manager.service.j2
│       │       └── kube-scheduler.service.j2
│       ├── etcd
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── restart_etcd.yml
│       │   ├── tasks
│       │   │   ├── configure.yml
│       │   │   ├── main.yml
│       │   │   └── service.yml
│       │   └── templates
│       │       ├── etcd.conf.j2
│       │       └── etcd.service.j2
│       ├── hardening
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   ├── configure_audit.yml
│       │   │   ├── configure_rbac.yml
│       │   │   ├── etcd_backup.yml
│       │   │   ├── main.yml
│       │   │   ├── network_policies.yml
│       │   │   └── remove_bootstrap.yml
│       │   └── templates
│       │       ├── default-network-policy.yaml.j2
│       │       └── rbac-config.yaml.j2
│       ├── kubelet
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── restart_kubelet.yml
│       │   ├── tasks
│       │   │   ├── configure_kubelet.yml
│       │   │   └── main.yml
│       │   └── templates
│       │       ├── kubelet-config.yaml.j2
│       │       └── kubelet.service.j2
│       ├── kube-proxy
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── handlers
│       │   │   └── restart_kube_proxy.yml
│       │   ├── tasks
│       │   │   ├── configure_kube_proxy.yml
│       │   │   └── main.yml
│       │   └── templates
│       │       ├── kube-proxy-config.yaml.j2
│       │       └── kube-proxy.service.j2
│       └── networking
│           ├── defaults
│           │   └── main.yml
│           ├── handlers
│           │   └── apply_coredns.yml
│           ├── tasks
│           │   ├── deploy_coredns.yml
│           │   └── main.yml
│           └── templates
│               └── coredns-deployment.yaml.j2
├── ansible-tree.md
├── check_requirements.sh
├── combine.sh
├── hosts.txt
├── provision_common.sh
├── provision_jumpbox.sh
├── README.md
└── Vagrantfile

61 directories, 113 files
```