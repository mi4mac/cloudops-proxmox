# Quick Installation Guide

## Prerequisites Checklist
- [ ] FortiSOAR 7.2.0+ installed
- [ ] Proxmox VE host accessible
- [ ] SSH access to Proxmox host (root or privileged user)
- [ ] Proxmox scripts deployed (see scripts folder in source)

## Installation Steps

### Step 1: Import Pack to FortiSOAR
1. Log in to FortiSOAR UI
2. Go to **Content Hub** → **Import**
3. Select all files in this folder (or ZIP archive)
4. Click **Import** and follow wizard

### Step 2: Deploy Scripts to Proxmox
This package does not include scripts. From the source repository, copy all scripts from the `scripts/` folder to `/root/` on your Proxmox host and run `chmod 644 /root/*.sh`.

### Step 3: Configure SSH Connector
1. FortiSOAR → **Automation** → **Connectors** → **SSH**
2. Create/Edit connector:
   - **Host**: Your Proxmox IP/hostname
   - **User**: root (or privileged user)
   - **Authentication**: SSH key or password
   - **Test Connection**
3. Note the connector UUID (needed if different from default)

### Step 4: Update Playbook Connector ID (if needed)
If your SSH connector has a different UUID:
1. Edit playbook: `> Provision VM Instances.json`
2. Find step: "Run Provisioning CMD"
3. Update `"config": "36787c2e-5ae6-4a55-a4f9-de80281aa40e"` with your connector UUID

### Step 5: Configure Global Variables
1. FortiSOAR → **Automation** → **Global Variables**
2. Set:
   - `Server_fqhn` = Your FortiSOAR FQDN
   - `infrastructure_team_email` = Your team email

### Step 6: Test
1. Navigate to **Service Management** → **VM Instances**
2. Click **Request VM Instance**
3. Fill form and submit
4. Check playbook execution logs if issues occur

## Verification
- [ ] Pack imported successfully
- [ ] Scripts deployed to `/root/` on Proxmox
- [ ] SSH connector tested and working
- [ ] Global variables configured
- [ ] Test VM request completed successfully
