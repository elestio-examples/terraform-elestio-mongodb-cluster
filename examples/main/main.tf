# main.tf

module "mongodb_cluster" {
  source             = "elestio-examples/mongodb-cluster/elestio"
  nodes_count        = 3
  project_id         = var.project_id
  mongodb_secret_key = "secret-string"
  config = {
    server_name   = "mongo"
    provider_name = "hetzner"
    datacenter    = "fsn1"
    server_type   = "SMALL-1C-2G"
    version       = "3-management"
    support_level = "level1"
    admin_email   = var.admin_email
  }
  ssh_key = {
    key_name    = var.ssh_key_name
    public_key  = var.ssh_public_key
    private_key = var.ssh_private_key
  }
}
