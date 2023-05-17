# AWS

Welcome to Amazon ECS Solution eShopOnContainers for Terraform!

## Prerequisites

* If your domain was not purchased in AWS, then you need to create a [public hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html) in Route53 and delegate your domain to the Amazon NS servers
* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
* Create your [access_key_id and secret_access_key](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html)
* Configure the AWS credentials on your machine `~/.aws/credentials`. You need to use the following format:

```shell
[AWS_PROFILE_NAME]
aws_access_key_id = YOUR_AWS_ACCESS_KEY
aws_secret_access_key = YOUR_AWS_SECRET_KEY
region = us-west-2
```

## Quick Start

Clone this repository.

```shell
git clone https://github.com/stuton/eShopOnContainers.git
```

## Prepare environment/site level variables
Go to our environment folder
```
cd providers/aws/envs/dev
```

Edit the `env.hcl` file according to your account settings.

### Example

`envs/dev/env.hcl`
```
locals {
  account_id = "000000000000"
  aws_region = "eu-west-3"

  bucket_name    = "terragrunt-state-aws-dev-eu-west-3" // must be unique name
  dynamodb_table_name = "terragrunt-locks-aws-dev-eu-west-3"

  domain = "example.com"
}
```

# Deployment
## Deploy
Running infrastructure (ECS cluster, database, rabbitmq, etc..)
```
TF_VAR_image_tag=linux-terraform terragrunt run-all apply --terragrunt-non-interactive --terragrunt-include-dir api-gateway --terragrunt-include-dir base
```
Running ECS services
```
TF_VAR_image_tag=linux-terraform terragrunt run-all apply --terragrunt-non-interactive --terragrunt-exclude-dir api-gateway --terragrunt-exclude-dir base
```
> Make sure you have set required environment variables properly.
## Destroy
Destroy ECS services
```
TF_VAR_image_tag=linux-terraform terragrunt run-all destroy --terragrunt-non-interactive --terragrunt-exclude-dir api-gateway --terragrunt-exclude-dir base
```
Destroy infrastructure (ECS cluster, database, rabbitmq, etc..)
```
TF_VAR_image_tag=linux-terraform terragrunt run-all destroy --terragrunt-non-interactive --terragrunt-include-dir api-gateway --terragrunt-include-dir base
```

# Options

### Getting key_pair for EC2 instances
```
aws ssm get-parameters --with-decryption --names /autoscaling/eshop/key_pair | jq -rc '.Parameters[].Value'
```
### Using Spot Instances
[Example](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/examples/ec2-autoscaling/main.tf#L228)

### Database instance class

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html#SQLServer.Concepts.General.InstanceClasses

# Troubleshooting

1. is nessesary to prevent error: Failed to create CoreCLR, HRESULT: 0x80004005
https://github.com/aws/amazon-ecs-agent/issues/3299

```python
"readonly_root_filesystem": false
```

2. If you see that ECS tasks is stucked in PROVISIONING status, consider increasing more CPU and MEMORY
