variable "project_id" {
  type        = string
  nullable    = false
  description = <<-EOF
    Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb#project_id) `#project_id`
  EOF
}

variable "nodes_count" {
  type        = number
  default     = 1
  description = <<-EOT
    The desired number of MongoDB instances.
    Minimum value: `1`.
    Maximum value: `5`.
    Default value: `1`.
  EOT

  validation {
    condition     = var.nodes_count >= 1 && var.nodes_count <= 5
    error_message = "Minimum `1`, maximum `5`."
  }
}

variable "config" {
  type = object({
    server_name   = string
    provider_name = string
    datacenter    = string
    server_type   = string
    version       = string
    support_level = string
    admin_email   = string
  })
  nullable    = false
  description = <<-EOF
    The same configuration will be applied on each node.
    [`#server_name` documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb#server_name)
    See [providers list](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/3_providers_datacenters_server_types)
    [`#version` documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb#version)
    [`#support_level` documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb#support_level)
    [`#admin_email` documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/mongodb#admin_email)
  EOF
}

variable "ssh_key" {
  type = object({
    key_name    = string
    public_key  = string
    private_key = string
  })
  nullable    = false
  sensitive   = true
  description = <<-EOF
    A local SSH connection is required to run the commands on all nodes to create the cluster.
  EOF
}

variable "mongodb_secret_key" {
  type        = string
  nullable    = false
  sensitive   = true
  description = <<-EOT
    Each mongodb instances in the cluster uses the mongodb_secret_key as the shared password for authenticating other nodes in the deployment.
    Only mongod instances with the correct key can join the cluster.
    You can generate a key using any method you choose.
    For example, the following operation `openssl rand -base64 756` uses openssl to generate a complex pseudo-random 1024 character string to use as a shared password.
  EOT

  validation {
    condition     = length(var.mongodb_secret_key) >= 7
    error_message = "Minimum length of 7 characters."
  }
}
