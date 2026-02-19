#!/usr/bin/env bash
set -uo pipefail

# Arguments from FortiSOAR:
# $1 = CT name

CT_NAME="${1:?CT name required}"

echo "=== Starting CT destruction for: ${CT_NAME} ==="

# Use full paths so script works when run via SSH (minimal PATH)
PCT="/usr/sbin/pct"

# pct list output format: VMID Status Lock Name (Name is last column; Lock can be empty)
echo "Looking up CTID for CT name: '${CT_NAME}'..."
CTID=$("${PCT}" list | awk -v name="${CT_NAME}" 'NR>1 && $NF == name {print $1}')

if [[ -z "${CTID:-}" ]]; then
  echo "ERROR: CT with name '${CT_NAME}' not found in pct list output:"
  "${PCT}" list
  exit 1
fi

echo "Found CTID: ${CTID}"

# Stop the CT (ignore errors if already stopped)
echo "Stopping CTID ${CTID}..."
set +e
"${PCT}" stop "${CTID}" 2>&1
STOP_EXIT=$?
set -e

if [[ $STOP_EXIT -eq 0 ]]; then
  echo "CT stopped successfully"
else
  echo "Note: CT stop returned exit code ${STOP_EXIT} (may already be stopped)"
fi

# Wait a moment for stop to complete
sleep 3

# Destroy the CT
echo "Destroying CTID ${CTID}..."
set +e
"${PCT}" destroy "${CTID}" 2>&1
DESTROY_EXIT=$?
set -e

if [[ $DESTROY_EXIT -eq 0 ]]; then
  echo "CT ${CT_NAME} (CTID ${CTID}) has been successfully destroyed"
  exit 0
else
  echo "ERROR: Failed to destroy CTID ${CTID} (exit code: ${DESTROY_EXIT})"
  echo "This error will be logged for troubleshooting"
  exit 1
fi

