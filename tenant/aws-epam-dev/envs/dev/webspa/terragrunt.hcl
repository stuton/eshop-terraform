include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-ecs-service"
}

dependency "ecs" {
  config_path = "../base"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    cluster_id = "fake-cluster_id"
    public_subnets = ["fake-public_subnet"]
    target_group_arns = ["arn:aws:iam:::fake-target_group_arn"]
    aws_cloudwatch_log_group_name = "fake-aws_cloudwatch_log_group_name"
  }
}

inputs = {
  name   = "webspa"
  image  = "winshiftq/webspa:linux-terraform"
  cluster_id = dependency.ecs.outputs.cluster_id
  public_subnets = dependency.ecs.outputs.public_subnets
  target_group_arns = dependency.ecs.outputs.target_group_arns
  aws_cloudwatch_log_group_name = dependency.ecs.outputs.aws_cloudwatch_log_group_name
}
