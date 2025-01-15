# Salt
This is a tool I've heard about and decided to give it a try as it resembles me of AWS SSM which I am very familiar with, it essentially allows me to manipulate the package instalation and it has a whole (working) example on how to boot strap the nodes with it. So I've created on Harvester a cloud-init to achieve that here's the relevante parts :

```yaml

#cloud-config
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - curl

users:
  - name: user
    groups: sudo
    shell: /bin/bash
    lock_passwd: true
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ssh-rsa xxxxx

runcmd:
  - - systemctl
    - enable
    - --now
    - qemu-guest-agent.service
  - echo "10.0.2.170 salt" >> /etc/hosts
  - curl -o /tmp/bootstrap-salt.sh -L https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh
  - sudo sh /tmp/bootstrap-salt.sh -P stable 3006.1

# Enable automatic updates
apt:
  primary:
    - arches: [default]
      uri: "http://archive.ubuntu.com/ubuntu"
      suites: [main, universe, restricted, multiverse]
  preserve_sources_list: true
  disable_suites: []
  conf:
    - name: Unattended-Upgrade
      content: |
        Unattended-Upgrade::Automatic-Reboot "true";
        Unattended-Upgrade::Automatic-Reboot-Time "02:00";
        Unattended-Upgrade::Remove-Unused-Dependencies "true";
        Unattended-Upgrade::MinimalSteps "true";

```

This is the relevant bit : 

```
  - echo "10.0.2.170 salt" >> /etc/hosts
  - curl -o /tmp/bootstrap-salt.sh -L https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh
  - sudo sh /tmp/bootstrap-salt.sh -P stable 3006.1
```

Once a node boots, it reports to my salt master (`tf/salt.tf`) by adding server `10.0.2.170` to my hosts file. On that node, assuming you installed salt master ( please look `install_master.sh` for steps to do so). It will be waiting for your acceptace, like this :

1. Added an extra node by adjusting the count to `10`, `terraform plan` output :

```bash
felipe@Armadillo:~/workspace$ terraform plan
harvester_virtualmachine.minion[8]: Refreshing state... [id=default/minion-8]
harvester_virtualmachine.omv-nfs: Refreshing state... [id=default/omv-nfs]
harvester_virtualmachine.minion[6]: Refreshing state... [id=default/minion-6]
harvester_virtualmachine.minion[2]: Refreshing state... [id=default/minion-2]
harvester_virtualmachine.salt-master: Refreshing state... [id=default/salt-master]
harvester_virtualmachine.minion[3]: Refreshing state... [id=default/minion-3]
harvester_virtualmachine.minion[0]: Refreshing state... [id=default/minion-0]
harvester_virtualmachine.minion[1]: Refreshing state... [id=default/minion-1]
harvester_virtualmachine.minion[5]: Refreshing state... [id=default/minion-5]
harvester_virtualmachine.minion[4]: Refreshing state... [id=default/minion-4]
harvester_virtualmachine.minion[7]: Refreshing state... [id=default/minion-7]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # harvester_virtualmachine.minion[9] will be created
  + resource "harvester_virtualmachine" "minion" {
      + cpu                  = 6
      + description          = "ubuntu24 minion image"
      + efi                  = true
      + hostname             = "minion-9"
      + id                   = (known after apply)
      + machine_type         = "q35"
      + memory               = "12Gi"
      + message              = (known after apply)
      + name                 = "minion-9"
      + namespace            = "default"
      + node_name            = (known after apply)
      + reserved_memory      = "100Mi"
      + restart_after_update = true
      + run_strategy         = "RerunOnFailure"
      + secure_boot          = false
      + state                = (known after apply)
      + tags                 = {
          + "app" = "nginx"
        }

      + cloudinit {
          + type                  = "noCloud"
          + user_data_secret_name = "minion-salt"
        }

      + disk {
          + access_mode        = (known after apply)
          + auto_delete        = true
          + boot_order         = 1
          + bus                = "virtio"
          + hot_plug           = (known after apply)
          + image              = "image-ffn9f"
          + name               = "rootdisk"
          + size               = "50Gi"
          + storage_class_name = (known after apply)
          + type               = "disk"
          + volume_mode        = (known after apply)
          + volume_name        = (known after apply)
        }

      + network_interface {
          + interface_name = (known after apply)
          + ip_address     = (known after apply)
          + mac_address    = (known after apply)
          + model          = "virtio"
          + name           = "nic-1"
          + network_name   = "default/vlan2"
          + type           = "bridge"
          + wait_for_lease = true
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

2. Apply by `terraform apply -auto-approve` and wait for :

```bash

```