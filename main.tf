resource "elestio_mongodb" "nodes" {
  count         = var.nodes_count
  project_id    = var.project_id
  server_name   = "${var.config.server_name}-${count.index}"
  server_type   = var.config.server_type
  provider_name = var.config.provider_name
  datacenter    = var.config.datacenter
  version       = var.config.version
  support_level = var.config.support_level
  admin_email   = var.config.admin_email
  ssh_public_keys = [
    {
      username = var.ssh_key.key_name
      key_data = var.ssh_key.public_key
    },
  ]

  connection {
    type        = "ssh"
    user        = "root"
    host        = self.cname
    private_key = file("/Users/adamkrim/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      # Delete default config and data only for subnodes
      count.index > 0 ? "rm -rf /opt/app/data/*" : "echo"
    ]
  }
}

resource "null_resource" "cluster_configuration" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    require_replace = join(",", concat([var.mongodb_secret_key], elestio_mongodb.nodes.*.id))
  }

  provisioner "local-exec" {
    command = templatefile("${path.module}/scripts/setup_cluster.sh.tftpl", {
      software_password  = elestio_mongodb.nodes[0].admin.password,
      nodes              = [for node in elestio_mongodb.nodes : tomap({ "id" = node.id, "ipv4" = node.ipv4 })]
      ssh_private_key    = var.ssh_key.private_key
      mongodb_secret_key = var.mongodb_secret_key
    })
  }
}
