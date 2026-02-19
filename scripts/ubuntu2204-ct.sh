#!/usr/bin/env bash
# Exit on error, but allow debugging
set -euo pipefail

# Redirect stderr to stdout for better error capture via SSH
exec 2>&1

# Arguments from FortiSOAR:
# $1 = CT name
# $2 = IP address
# $3 = CPU cores
# $4 = Memory MB
# $5 = Disk GB
# $6 = Swap MB (optional)
# $7 = Root password (optional, default: fortinet)

CT_NAME="${1:?CT name required}"
IP_ADDR="${2:?IP address required}"
CPU_CORES="${3:-2}"
MEM_MB="${4:-2048}"
DISK_GB="${5:-20}"
SWAP_MB="${6:-0}"
ROOT_PASSWORD="${7:-fortinet}"

# Adjust these to your Proxmox environment
NODE_NAME="pve"
STORAGE="local-lvm"
TEMPLATE="local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
BRIDGE="vmbr0"
VLAN_TAG="255"
GATEWAY="10.255.255.1"
CIDR_SUFFIX="/24"

# Use full paths so script works when run via SSH (minimal PATH)
# pvesh is in /usr/bin on Proxmox VE; pct is in /usr/sbin
PVESH="/usr/bin/pvesh"
PCT="/usr/sbin/pct"

CTID=$("${PVESH}" get /cluster/nextid 2>&1)
if [[ -z "${CTID}" ]]; then
    echo "ERROR: Failed to get next CTID from Proxmox"
    exit 1
fi

echo "Creating CTID ${CTID} (${CT_NAME}) from template ${TEMPLATE} on node ${NODE_NAME}..."
"${PCT}" create "${CTID}" "${TEMPLATE}" \
  --hostname "${CT_NAME}" \
  --cores "${CPU_CORES}" \
  --memory "${MEM_MB}" \
  --rootfs "${STORAGE}:${DISK_GB}" \
  --net0 "name=eth0,bridge=${BRIDGE},tag=${VLAN_TAG},ip=${IP_ADDR}${CIDR_SUFFIX},gw=${GATEWAY}" \
  --password "${ROOT_PASSWORD}" \
  --swap "${SWAP_MB}" \
  --features nesting=1

echo "Starting CTID ${CTID}..."
"${PCT}" start "${CTID}"

echo "PROXMOX_ID=${CTID}"

echo "VM ${CT_NAME} has been provisioned successfully"
