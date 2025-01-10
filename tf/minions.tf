resource "harvester_virtualmachine" "minion" {
  name                 = "minion-${count.index}"
  count = 0
  namespace            = "default"
  restart_after_update = true

  description = "ubuntu24 minion image"
  tags = {
    ssh-user = "ubuntu"
  }

  cpu    = 6
  memory = "12Gi"

  efi         = true
  secure_boot = false

  run_strategy    = "RerunOnFailure"
  hostname        = "minion-${count.index}"
  reserved_memory = "100Mi"
  machine_type    = "q35"

  network_interface {
    name           = "nic-1"
    network_name = "default/u-v2-low-mtu"
    type = "bridge"
    wait_for_lease = true
  }

  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = "50Gi"
    bus        = "virtio"
    boot_order = 1

    image       = "image-9hhhz"
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name    = "minion-salt"
    #user_data_secret_name    = "jelly-clone"

  }
    lifecycle {
        ignore_changes = [
            disk[0].image
        ]
    }
}
