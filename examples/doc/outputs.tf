output "nodes_admins" {
  value     = { for node in module.cluster.nodes : node.server_name => node.admin }
  sensitive = true
}

output "connection_string" {
  value     = module.cluster.connection_string
  sensitive = true
}
