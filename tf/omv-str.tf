resource "harvester_virtualmachine" "omv-nfs" {
  name                 = "omv-nfs"
  namespace            = "default"
  restart_after_update = true

  description = "K8s Default Storage Provider"
  tags = {
    ssh-user = "admin"
  }

  cpu    = 8
  memory = "16Gi"

  efi         = true
  secure_boot = false

  run_strategy    = "RerunOnFailure"
  hostname        = "omv-nfs"
  reserved_memory = "100Mi"
  machine_type    = "q35"

  network_interface {
    name           = "nic-1"
    network_name = "default/vlan2"
    type = "bridge"

  }

  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = "1024Gi"
    bus        = "virtio"
    boot_order = 2

    auto_delete = true
  }
  disk {
    name       = "cd-rom"
    type       = "cd-rom"
    size       = "2Gi"
    bus        = "sata"
    image = "default/image-h7swt"
    boot_order = 1

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
