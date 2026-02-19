#!/usr/bin/env bash
# Exit on error, but allow debugging
set -euo pipefail

# Redirect stderr to stdout for better error capture via SSH
exec 2>&1

# Arguments from FortiSOAR:
# $1 = VM name
# $2 = IP address
# $3 = CPU cores
# $4 = Memory MB
# $5 = Disk GB
# $6 = Root password (optional, default: fortinet; note: VMs require cloud-init template to set password)

VM_NAME="${1:?VM name required}"
IP_ADDR="${2:?IP address required}"
CPU_CORES="${3:-2}"
MEM_MB="${4:-2048}"
DISK_GB="${5:-20}"
ROOT_PASSWORD="${6:-fortinet}"

# Adjust these to your Proxmox environment
TEMPLATE_ID="9000"         # Rocky 9 VM template created from ISO
NODE_NAME="pve"
STORAGE="local-lvm"
BRIDGE="vmbr0"
VLAN_TAG="255"
GATEWAY="10.255.255.1"
CIDR_SUFFIX="/24"

# Derive VMID in a simple deterministic way from the name
VMID=$(( ( $(echo -n "$VM_NAME" | cksum | awk '{print $1}') % 50000 ) + 2000 ))

# Use full paths so script works when run via SSH (minimal PATH)
QM="/usr/sbin/qm"

# Verify qm command exists
if ! command -v "${QM}" &> /dev/null; then
    echo "ERROR: ${QM} not found. Check PATH or use full path."
    exit 1
fi

echo "Cloning template ${TEMPLATE_ID} to VMID ${VMID} with name ${VM_NAME} on node ${NODE_NAME}..."
"${QM}" clone "${TEMPLATE_ID}" "${VMID}" --full 1 --name "${VM_NAME}" --storage "${STORAGE}"

echo "Configuring VMID ${VMID} (CPU=${CPU_CORES}, MEM=${MEM_MB}MB, DISK=${DISK_GB}G, IP=${IP_ADDR})..."
"${QM}" set "${VMID}" \
  --cores "${CPU_CORES}" \
  --memory "${MEM_MB}" \
  --net0 "virtio,bridge=${BRIDGE},tag=${VLAN_TAG}" \
  --ipconfig0 "ip=${IP_ADDR}${CIDR_SUFFIX},gw=${GATEWAY}" \
  --scsi0 "${STORAGE}:${DISK_GB}"

echo "Starting VMID ${VMID}..."
"${QM}" start "${VMID}"

echo "PROXMOX_ID=${VMID}"

echo "VM ${VM_NAME} has been provisioned successfully"

