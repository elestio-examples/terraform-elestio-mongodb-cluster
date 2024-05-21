module "cluster" {
  source = "elestio-examples/mongodb-cluster/elestio"

  project_id      = elestio_project.project.id
  mongodb_version = null # null means latest version
  mongodb_pass    = "xxxxxxxxxxxxx"
  mongodb_keyfile = file("./keyfile") # openssl rand -base64 741 > ./keyfile

  configuration_ssh_key = {
    username    = "terraform"
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
