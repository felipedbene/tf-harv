terraform {
  required_providers {
    harvester = {
      source = "harvester/harvester"
      version = "0.6.6"
    }
  }
}

provider "harvester" {
  # Configuration options
  kubeconfig = "kubeconfig.yml"
}

