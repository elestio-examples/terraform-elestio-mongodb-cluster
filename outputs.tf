output "nodes" {
  description = "This is the created nodes full information"
  value       = elestio_mongodb.nodes
  sensitive   = true
}

output "connection_string" {
  value     = "mongodb://admin:${var.mongodb_pass}@${join(",", [for node in elestio_mongodb.nodes : "${node.cname}:17271"])}/?replicaSet=Cluster0"
  sensitive = true
}
