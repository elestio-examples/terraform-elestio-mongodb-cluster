<!-- BEGIN_TF_DOCS -->
# Elestio MongoDB Cluster Terraform module

Using this module, you can easily and quickly deploy a **MongoDB Cluster** on **Elestio** that is configured correctly and **ready to use**, without spending a lot of time on manual configuration.



## What it does ?

1. Uses [official](https://hub.docker.com/_/mongo) MongoDB docker image.
2. Creates `N` nodes.
3. Makes sure nodes can talk to each other and create the cluster.
4. Makes sure that new nodes always join the cluster.

## Usage

There is a [ready-to-deploy example](https://github.com/elestio-examples/terraform-elestio-mongodb-cluster/tree/main/examples/get_started) included in the [examples](https://github.com/elestio-examples/terraform-elestio-mongodb-cluster/tree/main/examples) folder but simple usage is as follows:

```hcl
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
```

## Examples

- [Get Started](https://github.com/elestio-examples/terraform-elestio-mongodb-cluster/tree/main/examples/get_started) - Ready-to-deploy example which creates MySQL Cluster on Elestio with Terraform in 5 minutes.

## Scale the cluster

If 2 nodes are no longer enough after the first `terraform apply`, modify `nodes_count` to 4 in the configuration and run `terraform apply` again.
This will add 2 more nodes to the cluster.

You can also reduce the number of nodes, the excess ones will leave the cluster cleanly at the next `terraform apply`.

## How to use the cluster

According to the [MongoDB documentation](https://www.mongodb.com/docs/drivers/node/current/fundamentals/connection/connect/#connect-to-a-replica-set), you can put several hosts in a connection string.</br>
Example: `mongodb://user:password@host1:17271,host2:17271,host3:17271/?replicaSet=Cluster0`

Use `terraform output cluster_database_admin` command to output your cluster connection string:

```bash
# cluster_database_admin
{
"command" = "mongodb://admin:*****@91.107.194.15:17271,128.140.93.48:17271/?replicaSet=Cluster0"
"hosts" = [
"91.107.194.15",
"128.140.93.48",
]
"password" = "*****"
"port" = "17271"
"user" = "admin"
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | The same configuration will be applied on each node.<br>[`#server_name` documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb#server_name)<br>See [providers list](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/3_providers_datacenters_server_types)<br>[`#version` documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb#version)<br>[`#support_level` documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb#support_level)<br>[`#admin_email` documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb#admin_email) | <pre>object({<br>    server_name   = string<br>    provider_name = string<br>    datacenter    = string<br>    server_type   = string<br>    version       = string<br>    support_level = string<br>    admin_email   = string<br>  })</pre> | n/a | yes |
| <a name="input_mongodb_secret_key"></a> [mongodb\_secret\_key](#input\_mongodb\_secret\_key) | Each mongodb instances in the cluster uses the mongodb\_secret\_key as the shared password for authenticating other nodes in the deployment.<br>Only mongod instances with the correct key can join the cluster.<br>You can generate a key using any method you choose.<br>For example, the following operation `openssl rand -base64 756` uses openssl to generate a complex pseudo-random 1024 character string to use as a shared password. | `string` | n/a | yes |
| <a name="input_nodes_count"></a> [nodes\_count](#input\_nodes\_count) | The desired number of MongoDB instances.<br>Minimum value: `1`.<br>Maximum value: `5`.<br>Default value: `1`. | `number` | `1` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb#project_id) `#project_id` | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | A local SSH connection is required to run the commands on all nodes to create the cluster. | <pre>object({<br>    key_name    = string<br>    public_key  = string<br>    private_key = string<br>  })</pre> | n/a | yes |
## Modules

No modules.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_database_admin"></a> [cluster\_database\_admin](#output\_cluster\_database\_admin) | The database connection secrets. |
| <a name="output_cluster_nodes"></a> [cluster\_nodes](#output\_cluster\_nodes) | All the information of the nodes in the cluster. |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_elestio"></a> [elestio](#provider\_elestio) | >= 0.7.1 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_elestio"></a> [elestio](#requirement\_elestio) | >= 0.7.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.0 |
## Resources

| Name | Type |
|------|------|
| [elestio_mongodb.nodes](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb) | resource |
| [null_resource.cluster_configuration](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
<!-- END_TF_DOCS -->
