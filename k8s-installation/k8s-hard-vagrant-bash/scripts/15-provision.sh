#!/bin/bash
echo "Starting automated provisioning sequence..."

vagrant provision jumpbox --provision-with distribute-files

vagrant provision master01 master02 --provision-with setup-controller
vagrant provision jumpbox --provision-with start-etcd-cluster
vagrant provision worker01 worker02 --provision-with setup-worker
vagrant provision loadbalancer --provision-with setup-lb

vagrant provision jumpbox --provision-with setup-networking
