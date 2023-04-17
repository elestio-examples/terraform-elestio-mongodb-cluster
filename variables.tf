variable "project_id" {
  type        = string
  description = "The ID of the project in which the MongoDB instances will be created"
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
  description = "The configuration will be applied on all MongoDB services."
}

variable "ssh_key" {
  type = object({
    key_name    = string
    public_key  = string
    private_key = string
  })
  description = "An SSH connection will be needed to run the bash commands on all services to create the cluster."
  sensitive   = true
}

variable "mongodb_secret_key" {
  type        = string
  description = <<-EOT
    Each mongodb instances in the cluster uses the mongodb_secret_key as the shared password for authenticating other nodes in the deployment.
    Only mongod instances with the correct key can join the cluster.
    You can generate a key using any method you choose.
    For example, the following operation `openssl rand -base64 756` uses openssl to generate a complex pseudo-random 1024 character string to use as a shared password.
  EOT
  sensitive   = true
}
