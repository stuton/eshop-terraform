# Azure

Welcome to Microsoft Azure Container Solution eShopOnContainers for Terraform!

### Prepare remote state store for Azure

Your Terraform state is stored using an Azure Blob Storage Container as a Terraform backend.

Prepare the resource group, the storage account, and the container, and update the **deployment_storage_resource_group_name** and the **deployment_storage_account_name** in the env.hcl file for each environment.

deployment_storage_resource_group_name: rg-terragrunt-state

deployment_storage_account_name: stateterragrunt

container_name: terraform-state
