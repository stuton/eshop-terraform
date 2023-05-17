## AWS
* Instruction for AWS [here](./providers/aws/README.md)

## Microsoft Azure
* Instruction for Azure [here](./providers/azure/README.md)

## Repository overview

This repository has 3 main folders

* [modules](./terraform-modules): Each module consists of a number of resources that are combined to satisfy a particular requirement. For instance, [aws-ecs-service](./terraform-modules/aws-ecs-service) has resources for ECS service definition, task definition, task related IAM roles. Frequently, these resources are combined while defining an ECS service.
* [providers](./providers) (solution eShopOnContainers): The solution eShopOnContainers in this category are designed to address end-to-end requirements for particular scenarios and particular cloud providers.
