module "cluster" {
  source = "elestio-examples/mongodb-cluster/elestio"

  project_id      = "xxxxxx"
  mongodb_pass    = "xxxxxx"
  mongodb_keyfile = file("./keyfile") # openssl rand -base64 741 > ./keyfile

  configuration_ssh_key = {
    username    = "something"
    public_key  = chomp(file("~/.ssh/id_rsa.pub"))
    private_key = file("~/.ssh/id_rsa")
  }

  nodes = [
    {
      server_name   = "mongodb-1"
      provider_name = "scaleway"
      datacenter    = "fr-par-1"
      server_type   = "SMALL-2C-2G"
    },
    {
      server_name   = "mongodb-2"
      provider_name = "scaleway"
      datacenter    = "fr-par-2"
      server_type   = "SMALL-2C-2G"
    },
    {
      server_name   = "mongodb-3"
      provider_name = "scaleway"
      datacenter    = "fr-par-2"
      server_type   = "SMALL-2C-2G"
    },
  ]
}

output "connection_string" {
  value     = module.cluster.connection_string
  sensitive = true
}
