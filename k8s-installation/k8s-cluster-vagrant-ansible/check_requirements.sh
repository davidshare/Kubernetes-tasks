#!/bin/bash

# Define minimum requirements
MIN_CPU_CORES=8
MIN_FREE_RAM_MB=8704   # 8.5GB in MB (6GB masters + 4GB workers + 1GB lb/jumpbox)
MIN_FREE_DISK_GB=100   # 100GB for VMs + caches

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Checking system requirements for Kubernetes cluster..."

# 1. Check CPU cores
TOTAL_CPU_CORES=$(nproc)
AVAILABLE_CPU_CORES=$TOTAL_CPU_CORES  # No reserved cores in Linux
echo -n "CPU Cores: Total=$TOTAL_CPU_CORES, Available=$AVAILABLE_CPU_CORES (Minimum: $MIN_CPU_CORES) - "
if [ "$AVAILABLE_CPU_CORES" -ge "$MIN_CPU_CORES" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL - Need at least $MIN_CPU_CORES cores${NC}"
    exit 1
fi

# 2. Check RAM
TOTAL_RAM_MB=$(free -m | awk '/Mem:/ {print $2}')
FREE_RAM_MB=$(free -m | awk '/Mem:/ {print $4}')
echo -n "RAM: Total=${TOTAL_RAM_MB}MB, Free=${FREE_RAM_MB}MB (Minimum: ${MIN_FREE_RAM_MB}MB) - "
if [ "$FREE_RAM_MB" -ge "$MIN_FREE_RAM_MB" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL - Need at least ${MIN_FREE_RAM_MB}MB free RAM${NC}"
    exit 1
fi

# 3. Check free disk space (check VirtualBox VMs dir or home)
DISK_PATH="$HOME/VirtualBox VMs"
FREE_DISK_GB=$(df -h "$DISK_PATH" 2>/dev/null | tail -1 | awk '{print int($4)}')
if [ -z "$FREE_DISK_GB" ]; then
    FREE_DISK_GB=$(df -h $HOME | tail -1 | awk '{print int($4)}')
    DISK_PATH="$HOME"
fi
echo -n "Free Disk Space at $DISK_PATH: ${FREE_DISK_GB}GB (Minimum: ${MIN_FREE_DISK_GB}GB) - "
if [ "$FREE_DISK_GB" -ge "$MIN_FREE_DISK_GB" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL - Need at least ${MIN_FREE_DISK_GB}GB free disk space${NC}"
    exit 1
fi

echo -e "${GREEN}All checks passed! Your system meets CPU, RAM, and disk requirements.${NC}"