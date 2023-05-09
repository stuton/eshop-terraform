# "readonly_root_filesystem": false
is nessesary to prevent error: Failed to create CoreCLR, HRESULT: 0x80004005
https://github.com/aws/amazon-ecs-agent/issues/3299

# If you see that ECS tasks is stucked in PROVISIONING status, consider increasing more CPU and MEMORY


# Database instance class

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html#SQLServer.Concepts.General.InstanceClasses

# Using Spot Instances
# Example: https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/examples/ec2-autoscaling/main.tf#L228

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
