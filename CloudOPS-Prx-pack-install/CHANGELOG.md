# Changelog – CloudOPS Proxmox Pack

## [1.1.0] – 2025-02-19

### Added

- **Root Password field**
  - New **Root Password** text field on the "Request VM Instance" form (optional, encrypted).
  - If provided, the password is used for the provisioned instance; if left empty, defaults to "fortinet".
  - Password is stored encrypted on the VM Instance record and passed to provisioning scripts.
  - LXC scripts (`rockylinux9-ct.sh`, `debian13-ct.sh`, `ubuntu2204-ct.sh`) accept password as 7th argument.
  - VM script (`rocky9-vm.sh`) accepts password as 6th argument (note: VMs require cloud-init template to set password).

- **DNS consistency for containers**
  - LXC provisioning scripts now pass `--nameserver 1.1.1.1` to `pct create` so container DNS matches the `dNS` value (`1.1.1.1`) stored in the Network Interfaces module and documented in the README.

### Changed

- **Provision VM Instances playbook**
  - Removed mock output from **Get Available Resources** and **Run Provisioning CMD** steps. The playbook now uses live SSH/connector output only.

## [1.0.0] – 2025-10-30

- Initial pack (FortiSOAR 7.2.0+).
- VM/CT request, approval, provision, and destroy workflows.
- Modules: VM Instances, Network Interfaces. Picklists: VM Type, VM Status.
