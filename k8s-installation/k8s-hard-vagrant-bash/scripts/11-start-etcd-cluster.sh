#!/bin/bash
set -e
source /home/vagrant/project/scripts/00-output-format.sh

SSH_KEY="/home/vagrant/.ssh/jumpbox_key"
task_echo "[Task 1] - Start ETCD cluster on master01 and master02"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no vagrant@master01 "sudo systemctl start etcd" &
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no vagrant@master02 "sudo systemctl start etcd" &

wait
sleep 10  # Allow cluster formation

task_echo "[Task 2] - Verify ETCD cluster"
/usr/bin/ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no vagrant@master01 "etcdctl member list --endpoints=https://192.168.56.11:2379 --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/etcd-server.crt --key=/etc/etcd/etcd-server.key"
/usr/bin/ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no vagrant@master02 "etcdctl member list --endpoints=https://192.168.56.12:2379 --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/etcd-server.crt --key=/etc/etcd/etcd-server.key"
/usr/bin/ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no vagrant@master01 "sudo ETCDCTL_API=3 etcdctl member list --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/etcd-server.crt --key=/etc/etcd/etcd-server.key"
/usr/bin/ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no vagrant@master02 "sudo ETCDCTL_API=3 etcdctl member list --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/etcd-server.crt --key=/etc/etcd/etcd-server.key"