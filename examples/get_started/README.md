# Get started : MongoDB Cluster with Terraform and Elestio

In this example, you will learn how to use this module to deploy your own MongoDB cluster with Elestio.

Some knowledge of [terraform](https://developer.hashicorp.com/terraform/intro) is recommended, but if not, the following instructions are sufficient.

</br>

## Prepare the dependencies

- [Sign up for Elestio if you haven't already](https://dash.elest.io/signup)

- [Get your API token in the security settings page of your account](https://dash.elest.io/account/security)

- [Download and install Terraform](https://www.terraform.io/downloads)

  You need a Terraform CLI version equal or higher than v0.14.0.
  To ensure you're using the acceptable version of Terraform you may run the following command: `terraform -v`

</br>

## Instructions

1. Rename `secrets.tfvars.example` to `secrets.tfvars` and fill in the values.

   This file contains the sensitive values to be passed as variables to Terraform.</br>
   You should **never commit this file** with git.

2. Run terraform with the following commands:

   ```bash
   terraform init
   terraform plan -var-file="secrets.tfvars" # to preview changes
   terraform apply -var-file="secrets.tfvars"
   terraform show
   ```

3. You can use the `terraform output` command to print the output block of your main.tf file:

   ```bash
   terraform output cluster_database_admin
   ```

</br>

## Scaling

If 2 nodes are no longer enough after the first `terraform apply`, modify `nodes_count` to 4 in the configuration and run `terraform apply` again.
This will add 2 more nodes to the cluster.

You can also reduce the number of nodes, the excess ones will leave the cluster cleanly at the next `terraform apply`.

</br>

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

</br>

## Testing

1. [Download MongoDB Compass](https://www.mongodb.com/try/download/compass)

2. Use the `terraform output cluster_database_admin` command to form independent connection strings with a single host

   - Node 0: `mongodb://admin:*****@91.107.194.15:17271`
   - Node 1: `mongodb://admin:*****@128.140.93.48:17271`

3. Connect **independently** to each of its connection strings on MongoDB Compass

4. Create a database, collection and document on the first node. You should see it automatically appear on the second node a few seconds later.

You can try turning off the first node on the [Elestio dashboard](https://dash.elest.io/).
The second node remains functional.
When you restart it, it automatically updates with the new data.
