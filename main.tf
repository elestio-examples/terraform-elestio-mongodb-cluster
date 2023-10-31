resource "elestio_mongodb" "nodes" {
  for_each = { for value in var.nodes : value.server_name => value }

  project_id       = var.project_id
  version          = var.mongodb_version
  default_password = var.mongodb_pass
  server_name      = each.value.server_name
  provider_name    = each.value.provider_name
  datacenter       = each.value.datacenter
  server_type      = each.value.server_type
  // Merge the module configuration_ssh_key with the optional ssh_public_keys attribute
  ssh_public_keys = concat(each.value.ssh_public_keys, [{
    username = var.configuration_ssh_key.username
    key_data = var.configuration_ssh_key.public_key
  }])

  // Optional attributes
  admin_email                                       = each.value.admin_email
  alerts_enabled                                    = each.value.alerts_enabled
  app_auto_updates_enabled                          = each.value.app_auto_update_enabled
  backups_enabled                                   = each.value.backups_enabled
  firewall_enabled                                  = each.value.firewall_enabled
  keep_backups_on_delete_enabled                    = each.value.keep_backups_on_delete_enabled
  remote_backups_enabled                            = each.value.remote_backups_enabled
  support_level                                     = each.value.support_level
  system_auto_updates_security_patches_only_enabled = each.value.system_auto_updates_security_patches_only_enabled

  connection {
    type        = "ssh"
    host        = self.ipv4
    private_key = var.configuration_ssh_key.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/app",
      "docker-compose down",
      each.value.server_name != var.nodes[0].server_name ? "rm -rf /opt/app/data/*" : "echo"
    ]
  }
}

resource "null_resource" "update_nodes_env" {
  triggers = {
    requires_replace = join(",", [for node in elestio_mongodb.nodes : node.id], [var.mongodb_keyfile])
  }

  provisioner "local-exec" {
    command = templatefile("${path.module}/scripts/setup_cluster.sh.tftpl", {
      ssh_private_key   = nonsensitive(var.configuration_ssh_key.private_key)
      software_password = nonsensitive(var.mongodb_pass),
      mongodb_keyfile   = nonsensitive(var.mongodb_keyfile)
      nodes             = [for node in elestio_mongodb.nodes : tomap({ "id" = node.id, "cname" = node.cname })]
    })
    quiet = true
  }
}
