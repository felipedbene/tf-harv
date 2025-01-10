resource "harvester_virtualmachine" "salt-master" {
  name                 = "salt-master"
  namespace            = "default"
  restart_after_update = true

  description = "Salt Master Node"
  tags = {
    ssh-user = "ubuntu"
  }

  cpu    = 4
  memory = "8Gi"

  efi         = true
  secure_boot = false

  run_strategy    = "RerunOnFailure"
  hostname        = "salt-master"
  reserved_memory = "100Mi"
  machine_type    = "q35"

  network_interface {
    name           = "nic-1"
    network_name = "default/vlan2"
    type = "bridge"
    wait_for_lease = true
  }

  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = "50Gi"
    bus        = "virtio"
    boot_order = 1

    image       = "image-ffn9f"
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name    = "base-clone"
  }
  lifecycle {
        ignore_changes = [
            disk[0].image
        ]
    }
}
