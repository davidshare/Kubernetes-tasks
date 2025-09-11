#!/bin/sh

set -e

PROJECT_DIR=/home/vagrant/project

source $PROJECT_DIR/scripts/00-output-format.sh

task_echo "[Task 1] - Install HAPROXY"
sudo apt-get install -y haproxy

task_echo "[Task 2] - Setup HAPROXY config"
cp haproxy.cfg /etc/haproxy/haproxy.cfg

task_echo "[Task 3] - Setup HAPROXY service"
sudo service haproxy restart
sudo service haproxy status

task_echo "[Task 4] - test HAPROXY"
curl https://192.168.56.30:6443/version -k
