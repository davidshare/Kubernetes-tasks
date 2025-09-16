#!/bin/bash

# Define cluster resource requirements for 1 master, 2 workers, 1 jumpbox
REQ_CPU_CORES=6           # 1 master (2 CPUs) + 2 workers (1 CPU each) + 1 jumpbox (1 CPU) + 1 buffer
REQ_RAM_MB=7168           # 1 master (3072MB) + 2 workers (2048MB each) + 1 jumpbox (512MB) + 10% buffer
REQ_DISK_GB=60            # 1 master (20GB) + 2 workers (20GB each) + 1 jumpbox (10GB) + 10% buffer

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Checking system requirements for 1-master, 2-worker, 1-jumpbox Kubernetes cluster..."

# Initialize variables for status tracking
CPU_STATUS="PASS"
RAM_STATUS="PASS"
DISK_STATUS="PASS"

# 1. CPU Check
# Install sysstat if not present (for mpstat)
if ! command -v mpstat &> /dev/null; then
    echo "Installing sysstat for mpstat..."
    sudo apt-get update && sudo apt-get install -y sysstat
fi

TOTAL_CPU_CORES=$(nproc)
# Get idle percentage from mpstat (single snapshot)
IDLE_PERCENT=$(mpstat 1 1 | grep -A 1 "all" | tail -1 | awk '{print $NF}')
USED_PERCENT=$(echo "100 - $IDLE_PERCENT" | bc -l)
USED_CPU_CORES=$(echo "$USED_PERCENT * $TOTAL_CPU_CORES / 100" | bc -l | awk '{printf "%.1f", $0}')
AVAILABLE_CPU_CORES=$(echo "$IDLE_PERCENT * $TOTAL_CPU_CORES / 100" | bc -l | awk '{printf "%.1f", $0}')
echo "CPU Check:"
echo "  Total Capacity: ${TOTAL_CPU_CORES} cores"
echo "  Used: ${USED_CPU_CORES} cores (${USED_PERCENT}%)"
echo "  Available: ${AVAILABLE_CPU_CORES} cores (${IDLE_PERCENT}%)"
echo "  Required: ${REQ_CPU_CORES} cores"
if [ "$(echo "$AVAILABLE_CPU_CORES >= $REQ_CPU_CORES" | bc -l)" -eq 1 ]; then
    echo -e "  Status: ${GREEN}PASS${NC}"
else
    echo -e "  Status: ${RED}FAIL - Need at least ${REQ_CPU_CORES} cores available${NC}"
    CPU_STATUS="FAIL"
fi
echo ""

# 2. RAM Check
TOTAL_RAM_MB=$(free -m | awk '/Mem:/ {print $2}')
USED_RAM_MB=$(free -m | awk '/Mem:/ {print $3}')
AVAILABLE_RAM_MB=$(free -m | awk '/Mem:/ {print $4}')
echo "RAM Check:"
echo "  Total Capacity: ${TOTAL_RAM_MB}MB"
echo "  Used: ${USED_RAM_MB}MB"
echo "  Available: ${AVAILABLE_RAM_MB}MB"
echo "  Required: ${REQ_RAM_MB}MB"
if [ "$AVAILABLE_RAM_MB" -ge "$REQ_RAM_MB" ]; then
    echo -e "  Status: ${GREEN}PASS${NC}"
else
    echo -e "  Status: ${RED}FAIL - Need at least ${REQ_RAM_MB}MB free RAM${NC}"
    RAM_STATUS="FAIL"
fi
echo ""

# 3. Disk Check
DISK_PATH="$HOME/VirtualBox VMs"
if [ ! -d "$DISK_PATH" ]; then
    DISK_PATH="$HOME"
fi
TOTAL_DISK_GB=$(df -h "$DISK_PATH" | tail -1 | awk '{print int($2)}')
USED_DISK_GB=$(df -h "$DISK_PATH" | tail -1 | awk '{print int($3)}')
AVAILABLE_DISK_GB=$(df -h "$DISK_PATH" | tail -1 | awk '{print int($4)}')
echo "Disk Check (at $DISK_PATH):"
echo "  Total Capacity: ${TOTAL_DISK_GB}GB"
echo "  Used: ${USED_DISK_GB}GB"
echo "  Available: ${AVAILABLE_DISK_GB}GB"
echo "  Required: ${REQ_DISK_GB}GB"
if [ "$AVAILABLE_DISK_GB" -ge "$REQ_DISK_GB" ]; then
    echo -e "  Status: ${GREEN}PASS${NC}"
else
    echo -e "  Status: ${RED}FAIL - Need at least ${REQ_DISK_GB}GB free disk space${NC}"
    DISK_STATUS="FAIL"
fi
echo ""

# Summary
echo "Summary of Requirements Check:"
echo -e "  CPU: ${CPU_STATUS}"
echo -e "  RAM: ${RAM_STATUS}"
echo -e "  Disk: ${DISK_STATUS}"
echo ""

if [ "$CPU_STATUS" = "PASS" ] && [ "$RAM_STATUS" = "PASS" ] && [ "$DISK_STATUS" = "PASS" ]; then
    echo -e "${GREEN}All checks passed! Your system meets the requirements for the Kubernetes cluster setup.${NC}"
else
    echo -e "${RED}One or more checks failed. Please ensure your system meets the minimum requirements before proceeding.${NC}"
    exit 1
fi
