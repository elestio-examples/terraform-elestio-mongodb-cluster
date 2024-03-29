# Get started : MongoDB Cluster with Terraform and Elestio

In this example, you will learn how to use this module to deploy your own MongoDB cluster with Elestio.

Some knowledge of [terraform](https://developer.hashicorp.com/terraform/intro) is recommended, but if not, the following instructions are sufficient.

## Prepare the dependencies

- [Sign up for Elestio if you haven't already](https://dash.elest.io/signup)

- [Get your API token in the security settings page of your account](https://dash.elest.io/account/security)

- [Download and install Terraform](https://www.terraform.io/downloads)

  You need a Terraform CLI version equal or higher than v0.14.0.
  To ensure you're using the acceptable version of Terraform you may run the following command: `terraform -v`

## Instructions

1. Rename `terraform.tfvars.example` to `terraform.tfvars` and fill in the values.

   This file contains the sensitive values to be passed as variables to Terraform.</br>
   You should **never commit this file** with git.

2. Generate your MongoDB keyfile using the following command:

```bash
openssl rand -base64 756 > keyfile
```

3. Run terraform with the following commands:

   ```bash
   terraform init
   terraform plan # to preview changes
   terraform apply
   terraform show
   ```

4. You can use the `terraform output` command to print the output block of your main.tf file:

   ```bash
   terraform output connection_string
   ```

## Scaling

If 3 nodes are no longer enough after the first `terraform apply`, modify `nodes_count` to 4 in the configuration and run `terraform apply` again.
This will add 1 more nodes to the cluster.

You can also reduce the number of nodes, the excess ones will leave the cluster cleanly at the next `terraform apply`.

## How to use the cluster

According to the [MongoDB documentation](https://www.mongodb.com/docs/drivers/node/current/fundamentals/connection/connect/#connect-to-a-replica-set), you can put several hosts in a connection string.</br>
Example: `mongodb://user:password@host1:17271,host2:17271,host3:17271/?replicaSet=Cluster0`

Use `terraform output connection_string` command to output your cluster connection string.
