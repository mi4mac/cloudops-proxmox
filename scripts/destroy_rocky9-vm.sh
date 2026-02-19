#!/usr/bin/env bash
set -uo pipefail

# Arguments from FortiSOAR:
# $1 = VM name

VM_NAME="${1:?VM name required}"

echo "=== Starting VM destruction for: ${VM_NAME} ==="

# Use full path so script works when run via SSH (minimal PATH)
QM="/usr/sbin/qm"

# qm list output format: VMID NAME STATUS MEM(MB) BOOTDISK(GB) PID
# Column 1 = VMID, Column 2 = NAME
echo "Looking up VMID for VM name: '${VM_NAME}'..."
VMID=$("${QM}" list | awk -v name="${VM_NAME}" '$2 == name {print $1}')

if [[ -z "${VMID:-}" ]]; then
  echo "ERROR: VM with name '${VM_NAME}' not found in qm list output:"
  "${QM}" list
  exit 1
fi

echo "Found VMID: ${VMID}"

# Stop the VM (ignore errors if already stopped)
echo "Stopping VMID ${VMID}..."
set +e
"${QM}" stop "${VMID}" 2>&1
STOP_EXIT=$?
set -e

if [[ $STOP_EXIT -eq 0 ]]; then
  echo "VM stopped successfully"
else
  echo "Note: VM stop returned exit code ${STOP_EXIT} (may already be stopped)"
fi

# Wait a moment for stop to complete
sleep 3

# Destroy the VM with purge
echo "Destroying VMID ${VMID}..."
set +e
"${QM}" destroy "${VMID}" --purge 2>&1
DESTROY_EXIT=$?
set -e

if [[ $DESTROY_EXIT -eq 0 ]]; then
  echo "VM ${VM_NAME} (VMID ${VMID}) has been successfully destroyed"
  exit 0
else
  echo "ERROR: Failed to destroy VMID ${VMID} (exit code: ${DESTROY_EXIT})"
  echo "This error will be logged for troubleshooting"
  exit 1
fi

