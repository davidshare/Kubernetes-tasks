#!/bin/sh
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo cp ca.crt etcd-server.key etcd-server.crt /etc/etcd/

sudo mv etcd etcdctl /usr/local/bin

INTERNAL_IP=$(ip addr show enp0s8 | grep "inet " | awk '{print $2}' | cut -d / -f 1)
echo $INTERNAL_IP
ETCD_NAME=$(hostname -s)
echo $ETCD_NAME

cat /etc/systemd/system/etcd.service

sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

## Confirm etcd status
sudo systemctl status etcd.service

## Check etcd master logs
sudo journalctl -u etcd.service --no-pager --output cat -f

etcdctl member list