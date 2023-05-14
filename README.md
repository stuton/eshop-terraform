# Installation

## AWS
1. Create public hosted zone with your domain
2. cd tenant/aws-epam-dev/envs/dev
3. terragrunt run-all apply --terragrunt-non-interactive --terragrunt-include-external-dependencies

## Microsoft Azure

### Prepare remote state store for Azure

Your Terraform state is stored using an Azure Blob Storage Container as a Terraform backend.

Prepare the resource group, the storage account, and the container, and update the **deployment_storage_resource_group_name** and the **deployment_storage_account_name** in the env.hcl file for each environment.

deployment_storage_resource_group_name: rg-terragrunt-state

deployment_storage_account_name: stateterragrunt

container_name: terraform-state

# Options
## Database instance class

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html#SQLServer.Concepts.General.InstanceClasses

### Using Spot Instances
[Example](https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/examples/ec2-autoscaling/main.tf#L228)

```hcl
ex-2 = {
    auto_scaling_group_arn         = module.autoscaling["ex-2"].autoscaling_group_arn
    managed_termination_protection = "ENABLED"

    managed_scaling = {
    maximum_scaling_step_size = 15
    minimum_scaling_step_size = 5
    status                    = "ENABLED"
    target_capacity           = 90
    }

    default_capacity_provider_strategy = {
    weight = 40
    }
}
```

# Troubleshooting

1. is nessesary to prevent error: Failed to create CoreCLR, HRESULT: 0x80004005
https://github.com/aws/amazon-ecs-agent/issues/3299

```python
"readonly_root_filesystem": false
```

2. If you see that ECS tasks is stucked in PROVISIONING status, consider increasing more CPU and MEMORY



