output "nodes" {
  value       = elestio_mongodb.nodes
  description = "The information of each MongoDB cluster nodes."
}

output "cluster_database_admin" {
  value = {
    command  = "mongodb://admin:${elestio_mongodb.nodes[0].admin.password}@${join(",", [for node in elestio_mongodb.nodes : "${node.ipv4}:17271"])}/?replicaSet=Cluster0",
    hosts    = elestio_mongodb.nodes.*.ipv4,
    password = elestio_mongodb.nodes[0].admin.password,
    port     = "17271",
    user     = "admin"
  }
  description = "The information to connect to the database."
}
