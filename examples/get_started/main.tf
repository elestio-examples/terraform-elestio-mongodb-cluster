terraform {
  required_providers {
    elestio = {
      source = "elestio/elestio"
    }
  }
}

provider "elestio" {
  email     = var.elestio_email
  api_token = var.elestio_api_token
}

resource "elestio_project" "project" {
  name            = "MongoDB Cluster"
  description     = "Ready-to-deploy terraform example"
  technical_email = var.elestio_email
}

module "cluster" {
  source = "elestio-examples/mongodb-cluster/elestio"
  # source = "../.." # If you want to use local version

  project_id = elestio_project.project.id

  nodes_count = 3
  # The same configuration will be applied to each node
  config = {
    server_name   = "mongo"
    provider_name = "hetzner"
    datacenter    = "fsn1"
    server_type   = "SMALL-1C-2G"
    version       = "6"
    support_level = "level1"
    admin_email   = var.elestio_email
  }

  mongodb_secret_key = var.mongodb_secret_key

  ssh_key = {
    key_name    = "admin"                          # or var.ssh_key.name
    public_key  = chomp(file("~/.ssh/id_rsa.pub")) # or var.ssh_key.public_key
    private_key = file("~/.ssh/id_rsa")            # or var.ssh_key.private_key
    # See variables.tf and secrets.tfvars file comments if your want to use variables instead file() function.
  }
}

# This output will contain the cluster connection string
output "cluster_database_admin" {
  value     = module.cluster.cluster_database_admin
  sensitive = true
}
