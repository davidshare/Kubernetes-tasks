#!/bin/sh

sudo apt-get install -y haproxy

cp haproxy.cfg /etc/haproxy/haproxy.cfg
sudo service haproxy restart
sudo service haproxy status

curl https://192.168.56.30:6443/version -k

sudo service haproxy restart