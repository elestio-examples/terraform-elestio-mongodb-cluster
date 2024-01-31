<!-- BEGIN_TF_DOCS -->
# Elestio MongoDB Cluster Terraform module

Using this module, you can easily and quickly deploy with **Terraform** a **MongoDB Cluster** on **Elestio** that is configured correctly and **ready to use**, without spending a lot of time on manual configuration.


## Module requirements

- The minimum number of nodes in a mongodb cluster is 3
- 1 Elestio account https://dash.elest.io/signup
- 1 API key https://dash.elest.io/account/security
- 1 SSH public/private key (see how to create one [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/ssh_keys))

## Usage

This is a minimal example of how to use the module:

```hcl
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
```

Keep your mongodb password safe, you will need it to access the admin panel.

If you want to know more about node configuration, check the mongodb service documentation [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb).

If you want to choose your own provider, datacenter or server type, check the guide [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/providers_datacenters_server_types).

If you want to generated a valid SSH Key, check the guide [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/ssh_keys).

If you add more nodes, you may attains the resources limit of your account, please visit your account [quota page](https://dash.elest.io/account/add-quota).

## Quick configuration

The following example will create a MongoDB cluster with 3 nodes.

You may need to adjust the configuration to fit your needs.

Create a `main.tf` file at the root of your project, and fill it with your Elestio credentials:

```hcl
terraform {
  required_providers {
    elestio = {
      source = "elestio/elestio"
    }
  }
}

provider "elestio" {
  email     = "xxxx@xxxx.xxx"
  api_token = "xxxxxxxxxxxxx"
}

resource "elestio_project" "project" {
  name = "MongoDB Cluster"
}
```

Generate your MongoDB keyfile using the following command:

```bash
openssl rand -base64 756 > keyfile
```

Now you can use the module to create mongodb nodes:

```hcl
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
```

To get a valid random mongodb password, you can use the url https://api.elest.io/api/auth/passwordgenerator

```bash
$ curl -s https://api.elest.io/api/auth/passwordgenerator
{"status":"OK","password":"7Tz1lCfD-Y8di-AyU2o467"}
```

Finally, let's add some outputs to retrieve useful information:

```hcl
output "nodes_admins" {
  value     = { for node in module.cluster.nodes : node.server_name => node.admin }
  sensitive = true
}

output "connection_string" {
  value     = module.cluster.connection_string
  sensitive = true
}
```

You can now run `terraform init` and `terraform apply` to create your MongoDB cluster.
After a few minutes, the cluster will be ready to use.
You can access your outputs with `terraform output`:

```bash
$ terraform output nodes_admins
$ terraform output connection_string
```

If you want to update some parameters, you can edit the `main.tf` file and run `terraform apply` again.
Terraform will automatically update the cluster to match the new configuration.
Please note that changing the node count requires to change the .env of existing nodes. This is done automatically by the module.

## Ready-to-deploy example

We created a MongoDB ready-to-deploy cluster example which creates the same infrastructure as the previous example.
You can find it [here](https://github.com/elestio-examples/terraform-elestio-mongodb-cluster/tree/main/examples/get_started).
Follow the instructions to deploy the example.

## How to use the cluster

According to the [MongoDB documentation](https://www.mongodb.com/docs/drivers/node/current/fundamentals/connection/connect/#connect-to-a-replica-set), you can put several hosts in a connection string.

Example: `mongodb://user:password@host1:17271,host2:17271,host3:17271/?replicaSet=Cluster0`

Use `terraform output connection_string` command to output database secrets:

```bash
$ terraform output connection_string
"mongodb://*****:******@mongodb-1-u525.vm.elestio.app:17271,mongodb-2-u525.vm.elestio.app:17271,mongodb-3-u525.vm.elestio.app:17271/?replicaSet=Cluster0"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configuration_ssh_key"></a> [configuration\_ssh\_key](#input\_configuration\_ssh\_key) | After the nodes are created, Terraform must connect to apply some custom configuration.<br>This configuration is done using SSH from your local machine.<br>The Public Key will be added to the nodes and the Private Key will be used by your local machine to connect to the nodes.<br><br>Read the guide [\"How generate a valid SSH Key for Elestio\"](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/ssh_keys). Example:<pre>configuration_ssh_key = {<br>  username = "admin"<br>  public_key = chomp(file("\~/.ssh/id_rsa.pub"))<br>  private_key = file("\~/.ssh/id_rsa")<br>}</pre> | <pre>object({<br>    username    = string<br>    public_key  = string<br>    private_key = string<br>  })</pre> | n/a | yes |
| <a name="input_mongodb_keyfile"></a> [mongodb\_keyfile](#input\_mongodb\_keyfile) | The nodes will use this key to authenticate each other.<br>Read [How to generate a keyfile](https://www.mongodb.com/docs/v2.4/tutorial/generate-key-file).<br>For example, the following operation `openssl rand -base64 741 > ./keyfile`:<pre>mongodb_keyfile = file("./keyfile")</pre> | `string` | n/a | yes |
| <a name="input_mongodb_pass"></a> [mongodb\_pass](#input\_mongodb\_pass) | Require at least 10 characters, one uppercase letter, one lowercase letter and one number.<br>Generate a random valid password: https://api.elest.io/api/auth/passwordgenerator | `string` | n/a | yes |
| <a name="input_mongodb_version"></a> [mongodb\_version](#input\_mongodb\_version) | The cluster nodes must share the same mongodb version.<br>Leave empty or set to `null` to use the Elestio recommended version. | `string` | `null` | no |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Each element of this list will create an Elestio MongoDB Resource in your cluster.<br>Read the following documentation to understand what each attribute does, plus the default values: [Elestio KeyDB Resource](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb). | <pre>list(<br>    object({<br>      server_name                                       = string<br>      provider_name                                     = string<br>      datacenter                                        = string<br>      server_type                                       = string<br>      admin_email                                       = optional(string)<br>      alerts_enabled                                    = optional(bool)<br>      app_auto_update_enabled                           = optional(bool)<br>      backups_enabled                                   = optional(bool)<br>      firewall_enabled                                  = optional(bool)<br>      keep_backups_on_delete_enabled                    = optional(bool)<br>      remote_backups_enabled                            = optional(bool)<br>      support_level                                     = optional(string)<br>      system_auto_updates_security_patches_only_enabled = optional(bool)<br>      ssh_public_keys = optional(list(<br>        object({<br>          username = string<br>          key_data = string<br>        })<br>      ), [])<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
## Modules

No modules.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | n/a |
| <a name="output_nodes"></a> [nodes](#output\_nodes) | This is the created nodes full information |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_elestio"></a> [elestio](#provider\_elestio) | >= 0.14.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_elestio"></a> [elestio](#requirement\_elestio) | >= 0.14.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.0 |
## Resources

| Name | Type |
|------|------|
| [elestio_mongodb.nodes](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb) | resource |
| [null_resource.update_nodes_env](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
<!-- END_TF_DOCS -->
