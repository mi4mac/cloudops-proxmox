# CloudOPS Proxmox Pack for FortiSOAR

## Overview
This FortiSOAR content pack provides automated VM and Container lifecycle management for Proxmox VE environments. It enables users to request, approve, provision, and destroy virtual machines and containers through FortiSOAR playbooks.

## Requirements
- FortiSOAR version 7.2.0 or higher
- Proxmox VE host accessible via SSH
- SSH connector configured in FortiSOAR with root (or privileged) access to Proxmox host

## Installation

### 1. Install the FortiSOAR Pack
1. Log in to your FortiSOAR instance
2. Navigate to **Content Hub** → **Import**
3. Upload the entire `CloudOPS-Prx-pack-install` folder or create a ZIP archive and import it
4. Follow the import wizard to install all components

### 2. Deploy Proxmox Scripts (Required)
**IMPORTANT:** This package does not include Proxmox scripts. The pack requires provisioning and destroy scripts on your Proxmox host. Obtain them from the project's `scripts/` folder in the source repository, copy them to `/root/` on your Proxmox server, and set permissions (e.g. `chmod 644 /root/*.sh`). The SSH connector user (typically root) must be able to run them.

**Note for VM scripts:** The VM provisioning script (`rocky9-vm.sh`) requires a **golden image (template VM)** to be created in Proxmox first. The script clones from this template using `qm clone`. By default, the script uses `TEMPLATE_ID="9000"` - ensure you have a VM template with this ID, or update the `TEMPLATE_ID` variable in the script to match your template's VMID. To create a template: install and configure your base VM, then convert it to a template using `qm template <vmid>` in Proxmox.

### 3. Configure SSH Connector
1. In FortiSOAR, go to **Automation** → **Connectors**
2. Configure an SSH connector pointing to your Proxmox host
3. Ensure the connector uses root (or a user with sudo access to `qm` and `pct` commands)
4. Test the connection

**Connector Configuration ID:** `36787c2e-5ae6-4a55-a4f9-de80281aa40e`  
*(Update this in the playbook if your connector has a different ID)*

### 4. Configure Global Variables
After installation, configure these global variables in FortiSOAR:
- `Server_fqhn` - FortiSOAR server FQDN (default: master.fortisoar.in)
- `infrastructure_team_email` - Email for infrastructure team notifications (default: cloud-ops@fortielab.com)

## Components Included

### Modules
- **VM Instances** (`v_m_instances`) - Tracks VM/CT requests and instances
- **Network Interfaces** (`network_interfaces`) - Manages IP configuration

### Playbooks
- **Request VM Instance** - Main workflow for requesting VMs/CTs
- **Provision VM Instances** - Automated provisioning
- **Destroy VM Instance** - VM/CT destruction
- **Destroy Expired VM Instances** - Automated cleanup
- **Manage Service Request** - Service request management
- **AD User Enrichment** - Active Directory integration
- **Get Public FortiSOAR URL** - URL retrieval utility

### Picklists
- **VM Type**: Rocky9-VM, Debian13-CT, RockyLinux9-CT, Ubuntu2204-CT
- **VM Status**: Active, Pending Approval, Failed, Destroyed, Rejected

### Roles
- **SOC Analyst** - Limited read permissions
- **Full App Permissions** - Full access

## Usage

1. Navigate to **Service Management** → **VM Instances**
2. Click **Request VM Instance** action button
3. Fill in the request form:
   - VM Name (alphanumeric + underscore only)
   - VM Type (Rocky9-VM, Debian13-CT, RockyLinux9-CT, or Ubuntu2204-CT)
   - CPU Cores, Memory (MB), Disk (GB)
   - Business Justification (required)
   - Optional: Delete After date for auto-cleanup
4. Submit the request
5. The system will:
   - Validate the request
   - Find an available IP address (10.255.255.129-191)
   - Create network interface record
   - Trigger approval workflow
   - Provision the VM/CT on Proxmox
   - Send notification emails

## Network Configuration

The pack uses the following network settings (configurable in scripts):
- **Subnet**: 10.255.255.0/24
- **Gateway**: 10.255.255.1
- **IP Range**: 10.255.255.129-191 (63 addresses)
- **VLAN**: 255
- **Bridge**: vmbr0
- **DNS**: 1.1.1.1

**Note:** While the DNS setting in the FortiSOAR playbook (Network Interfaces module) is set to `1.1.1.1`, the provisioning scripts currently use the **Proxmox server's DNS configuration** for the provisioned instances. The scripts do not explicitly set DNS via `--nameserver` in `pct create`, so instances inherit the Proxmox host's DNS settings. To use a specific DNS server (like 1.1.1.1), modify the scripts to add `--nameserver 1.1.1.1` to the `pct create` command.

## Troubleshooting

### Scripts Not Found (Exit Code 127)
- Verify scripts are in `/root/` on Proxmox host
- Check file permissions: `ls -la /root/*.sh`
- Test manually: `/usr/bin/bash /root/debian13-ct.sh testvm 10.255.255.100 2 2048 20 0` (or the script for your chosen VM type)

### Permission Denied
- Ensure SSH connector runs as root or user with sudo access
- SSH connector should log in as root (no super_user flag needed)
- Test SSH access: `ssh user@proxmox-host "whoami"`

### CT/VM Not Found During Destruction
- Fixed in latest version: Scripts now use `$NF` (last column) instead of `$4` for name matching
- Ensure you're using the updated destroy scripts

### Provisioning Fails
- Check Proxmox host resources (disk space, memory)
- Verify template IDs exist (Rocky 9 template ID: 9000)
- Check Proxmox logs: `journalctl -u pve-cluster`

## Support

For issues or questions:
- Check FortiSOAR playbook execution logs
- Review Proxmox system logs
- Verify SSH connector configuration
- Ensure all scripts are deployed and have correct permissions

## Version Information
- **Pack Version**: 1.1.0
- **Release Date**: 2025-02-19
- **Minimum FortiSOAR Version**: 7.2.0
- **Changelog**: See **CHANGELOG.md** in this folder.
