# Terraform Setup for Azure

## Prerequisites

You'll need:

- An Azure subscription with permissions to create resources (Contributor is enough)
- Azure CLI (`az`)
- Terraform (`terraform`)

Verify installs:

```bash
az version
terraform version
```

## Azure Authentication

Login to Azure and configure your subscription:

```bash
az login
az account show
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

Replace `<SUBSCRIPTION_ID_OR_NAME>` with your actual subscription ID or subscription name.

## Running Terraform

```bash
# Initial setup
terraform init

# Review changes
terraform plan

# Apply changes
terraform apply

# Clean up when done
terraform destroy
```
