# Installation

Ensure that [Terraform](https://developer.hashicorp.com/terraform/downloads) and [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) are set up and installed in your environment. After that, you may launch the scripts listed below from the /src/ directory and begin using the eShopOnContainers right away.

## AWS
* Instruction for AWS [here](https://github.com/stuton/eshop-terraform/blob/main/tenant/aws-epam-dev/README.md)

## Microsoft Azure
* Instruction for Azure [here](https://github.com/stuton/eshop-terraform/blob/main/tenant/azure-epam-dev/README.md)

## Repository overview

This repository has 3 main folders

* [modules](./terraform-modules): Each module consists of a number of resources that are combined to satisfy a particular requirement. For instance, [aws-ecs-service](./terraform-modules/aws-ecs-service) has resources for ECS service definition, task definition, task related IAM roles. Frequently, these resources are combined while defining an ECS service.
* [tenant](./tenant) (solution eShopOnContainers): The solution eShopOnContainers in this category are designed to address end-to-end requirements for particular scenarios and particular cloud providers.
