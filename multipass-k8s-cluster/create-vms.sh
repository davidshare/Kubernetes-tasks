#!/bin/bash

# Launch VMs with multipass
multipass launch --name jumpbox --cpus 1 --memory 512M --disk 5G --cloud-init config/debian-cloud-init.yaml
multipass launch --name master --cpus 1 --memory 2G --disk 10G --cloud-init config/debian-cloud-init.yaml
multipass launch --name worker1 --cpus 1 --memory 2G --disk 10G --cloud-init config/debian-cloud-init.yaml
multipass launch --name workder2 --cpus 1 --memory 2G --disk 10G --cloud-init config/debian-cloud-init.yaml 