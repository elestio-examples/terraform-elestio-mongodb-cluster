# Terraform module to create a simple MongoDB cluster on Elestio

Using this module, you can easily and quickly deploy a **MongoDB Cluster** on **Elestio** that is configured correctly and **ready to use**, without spending a lot of time on manual configuration.

## What it does ?

1. Uses [official](https://hub.docker.com/_/mongodb/) MongoDB docker image.
2. Creates `N` nodes.
3. Makes sure nodes can talk to each other and create the cluster.
4. Makes sure that new nodes always join the cluster.

<!-- BEGIN_TF_DOCS -->


## How to use it ?

Copy and paste into your Terraform configuration:

```hcl
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

# This output will contain the database connection string
output "cluster_database_admin" {
  value     = module.mongodb_cluster.cluster_database_admin
  sensitive = true
}
```

Customize the variables in a `*.tfvars` file:
```hcl
# secrets.tfvars

project_id = "2500"
mongodb_secret_key = "SecureAndSecretString"
admin_email = "admin@email.com"
ssh_key_name = "Admin"
ssh_public_key = file("~/.ssh/id_rsa.pub")
ssh_private_key = file("~/.ssh/id_rsa")
```

Then run :
1. `terraform init`
2. `terraform plan -var-file="secrets.tfvars"`
3. `terraform apply -var-file="secrets.tfvars"`

## Scale the nodes

If 3 nodes are no longer enough, modify `nodes_count` to 5 in the configuration and run `terraform apply` again.
This will add 2 more nodes to the cluster.

You can also reduce the number of nodes, the excess ones will leave the cluster cleanly at the next `terraform apply`.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | The configuration will be applied on all MongoDB services. | <pre>object({<br>    server_name   = string<br>    provider_name = string<br>    datacenter    = string<br>    server_type   = string<br>    version       = string<br>    support_level = string<br>    admin_email   = string<br>  })</pre> | n/a | yes |
| <a name="input_mongodb_secret_key"></a> [mongodb\_secret\_key](#input\_mongodb\_secret\_key) | Each mongodb instances in the cluster uses the mongodb\_secret\_key as the shared password for authenticating other nodes in the deployment.<br>Only mongod instances with the correct key can join the cluster.<br>You can generate a key using any method you choose.<br>For example, the following operation `openssl rand -base64 756` uses openssl to generate a complex pseudo-random 1024 character string to use as a shared password. | `string` | n/a | yes |
| <a name="input_nodes_count"></a> [nodes\_count](#input\_nodes\_count) | The desired number of MongoDB instances.<br>Minimum value: `1`.<br>Maximum value: `5`.<br>Default value: `1`. | `number` | `1` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the MongoDB instances will be created | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | An SSH connection will be needed to run the bash commands on all services to create the cluster. | <pre>object({<br>    key_name    = string<br>    public_key  = string<br>    private_key = string<br>  })</pre> | n/a | yes |
## Modules

No modules.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_database_admin"></a> [cluster\_database\_admin](#output\_cluster\_database\_admin) | The information to connect to the database. |
| <a name="output_nodes"></a> [nodes](#output\_nodes) | The information of each MongoDB cluster nodes. |
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
