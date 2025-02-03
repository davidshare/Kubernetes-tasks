#!/bin/sh

setup_loadbalancer(){
  scp ../config/haproxy.cfg vagrant@loadbalancer:/etc/haproxy/haproxy.cfg
  sudo service haproxy restart
  sudo service haproxy status
}

verify_loadbalancer(){
  curl  https://192.168.56.30:6443/version -k
}