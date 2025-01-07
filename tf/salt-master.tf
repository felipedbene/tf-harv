resource "harvester_virtualmachine" "minions" {
  name                 = "salt-master"
  namespace            = "default"
  restart_after_update = true

  description = "Salt Master Node"
  tags = {
    ssh-user = "ubuntu"
  }

  cpu    = 8
  memory = "16Gi"

  efi         = true
  secure_boot = false

  run_strategy    = "RerunOnFailure"
  hostname        = "salt-master"
  reserved_memory = "100Mi"
  machine_type    = "q35"

  network_interface {
    name           = "nic-1"
    network_name = "default/u-v2"
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
    user_data_secret_name    = "jelly-clone"
    network_data_secret_name = "jelly-clone"
  }
}
