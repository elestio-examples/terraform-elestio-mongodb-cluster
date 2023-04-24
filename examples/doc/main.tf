module "mongodb_example_cluster" {
  source = "elestio-examples/mongodb-cluster/elestio"

  project_id = "1234"

  nodes_count = 2
  # The same configuration will be applied to each node
  config = {
    server_name   = "mongo"
    provider_name = "hetzner"
    datacenter    = "fsn1"
    server_type   = "SMALL-1C-2G"
    version       = "6"
    support_level = "level1"
    admin_email   = "admin@example.com"
  }

  mongodb_secret_key = "secret-string..."

  ssh_key = {
    key_name    = "admin"
    public_key  = file("~/.ssh/id_rsa.pub")
    private_key = file("~/.ssh/id_rsa")
  }
}

# This output will contain the cluster connection string
output "cluster_database_admin" {
  value     = module.mongodb_example_cluster.cluster_database_admin
  sensitive = true
}
