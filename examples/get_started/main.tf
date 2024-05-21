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
  name = "mongodb-cluster"
}


module "cluster" {
  source = "elestio-examples/mongodb-cluster/elestio"

  project_id      = elestio_project.project.id
  mongodb_version = null # null means latest version
  mongodb_pass    = var.mongodb_pass
  mongodb_keyfile = file("./keyfile")

  configuration_ssh_key = {
    username    = "admin"
    public_key  = chomp(file("~/.ssh/id_rsa.pub"))
    private_key = file("~/.ssh/id_rsa")
  }

  nodes = [
    {
      server_name   = "mongodb-1"
      provider_name = "hetzner"
      datacenter    = "fsn1"
      server_type   = "SMALL-1C-2G"
    },
    {
      server_name   = "mongodb-2"
      provider_name = "hetzner"
      datacenter    = "fsn1"
      server_type   = "SMALL-1C-2G"
    },
    {
      server_name   = "mongodb-3"
      provider_name = "hetzner"
      datacenter    = "fsn1"
      server_type   = "SMALL-1C-2G"
    },
  ]
}

output "nodes_admins" {
  value     = { for node in module.cluster.nodes : node.server_name => node.admin }
  sensitive = true
}

output "connection_string" {
  value     = module.cluster.connection_string
  sensitive = true
}
