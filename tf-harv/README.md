
# Repo for Testing Harvester Terraform Provider

This repository was created to document my exploration of DevOps technologies and share insights I've gained along the way. It serves as a personal journal and a resource for others who might face similar challenges.

---

## Why I Built This

While studying for the Kubernetes Certified Administrator (CKA) certification by @sandervanvug, I realized I needed a flexible, on-premises solution to meet the following goals:

- Provision a lightweight, updated Linux base image.
- Deploy baseline components to nodes with minimal manual intervention.
- Configure Kubernetes Control Plane and Worker Nodes dynamically.
- Scale infrastructure up or down as needed.
- Use on-premises technology to deepen my understanding of real-world setups, avoiding the simplicity of cloud providers like AWS.
- Ensure the solution is reproducible and portable.

These requirements led me to Harvester, a Kubernetes-based hyper-converged infrastructure (HCI) platform. Harvester supports Terraform and GPU passthrough, making it an ideal choice for this project.

---

## 1. Running Terraform Commands with Docker on WSL

To use Terraform with Harvester, I opted to run it in a containerized environment. Here’s how you can set up Docker on WSL and configure Terraform to run seamlessly.

### Install Docker on WSL

1. **Install WSL**:
   Ensure WSL 2 is installed and running. If not, follow [Microsoft's WSL installation guide](https://learn.microsoft.com/en-us/windows/wsl/install).

2. **Install Docker Desktop**:
   - Download and install Docker Desktop from [here](https://www.docker.com/products/docker-desktop/).
   - During installation, enable the WSL 2 backend and choose the distributions you want to integrate with Docker.

3. **Verify Installation**:
   - Open a WSL terminal and run:
     ```bash
     docker --version
     docker run hello-world
     ```
   - If both commands execute successfully, Docker is ready to use.

---

### Configure Terraform with Docker

To simplify running Terraform, I created an alias to use Terraform inside a Docker container. Add this alias to your `.bash_aliases` or `.zshrc` file:
```bash
alias terraform='docker run --rm -it --volume "/home/$(whoami)/workspace/tf-harv/tf:/terraform" --workdir "/terraform" --network host hashicorp/terraform:latest'
```
- **Volume Mapping**: Mounts your Terraform directory (`/home/$(whoami)/workspace/tf-harv/tf`) into the container.
- **Working Directory**: Sets the container's working directory to `/terraform`.
- **Networking**: Uses the host network for connectivity.

### Test the Configuration
After setting up the alias, test it by running:
```bash
terraform version
```
This command should display the Terraform version from the container.

---

## 2. Getting Started with Harvester

Before using Terraform, you need to deploy Harvester. Here's a quick overview:

1. **Install Harvester**:
   - Download the Harvester ISO from the [official releases page](https://github.com/harvester/harvester/releases).
   - Create a bootable USB or deploy it in a virtualized environment.
   - Follow the [Harvester Quick Start Guide](https://docs.harvesterhci.io/v1.4/quick-start/) for installation.

2. **Configure the Cluster**:
   - After installation, access the Harvester UI via the management IP.
   - Set up storage pools, network configurations, and cluster settings.

3. **Create a Machine Image**:
   - Go to **Virtualization > Images** in the Harvester UI.
   - Add a new image using the URL for an official cloud-init-enabled Ubuntu image:
     ```
     https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img
     ```
   - Wait for the image to be processed and ensure its status is **Active**.

---

## 3. Setting Up the Terraform Provider

Create a `provider.tf` file with the following content:
```hcl
terraform {
  required_providers {
    harvester = {
      source = "harvester/harvester"
      version = "0.6.6"
    }
  }
}

provider "harvester" {
  kubeconfig = "kubeconfig.yml"
}
```
- The `kubeconfig.yml` file contains credentials and cluster details. Download it from the Harvester UI (instructions [here](https://docs.harvesterhci.io/v1.4/faq)).
- **Important**: Add `kubeconfig.yml` to `.gitignore` to prevent exposing sensitive information.

---

## 4. Provisioning Nodes with Terraform

Here’s a sample Terraform configuration (`minion.tf`) to deploy nine Worker Nodes:
```hcl
resource "harvester_virtualmachine" "minion" {
  name                 = "minion-${count.index}"
  count                = 9
  namespace            = "default"
  restart_after_update = true

  description = "Ubuntu 24 Minion Image"
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
    network_name   = "default/vlan2"
    type           = "bridge"
    wait_for_lease = true
  }

  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = "50Gi"
    bus        = "virtio"
    boot_order = 1

    image       = "ubuntu24"
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name = "minion-salt"
  }

  lifecycle {
    ignore_changes = [disk[0].image]
  }
}
```

Deploy the nodes with:
```bash
terraform plan && terraform apply
```
Refer to `tf/` folder for the full resuling file.
---

## 5. Common Issues and Troubleshooting

Mail me for questions felipe [ at ] debene [ . ] xyz.

---
