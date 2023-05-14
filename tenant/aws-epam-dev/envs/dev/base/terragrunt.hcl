include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-ecs"

  common_tags = {
    Environment = "dev"
  }
}

inputs = {
  app_name = "eshop"
  vpc_cidr = "10.0.0.0/16"

  create_mq         = true
  mq_engine_type    = "RabbitMQ"
  mq_engine_version = "3.10.20"

  create_database_instance      = true
  database_instance_name        = "eshop"
  database_engine               = "sqlserver-ex"
  database_engine_version       = "14.00.3451.2.v1"   //"15.00.4236.7.v1"
  database_family               = "sqlserver-ex-14.0" //"sqlserver-ex-15.0"
  database_major_engine_version = "14.00"             //"15.00"
  database_instance_class       = "db.t2.micro"       //"db.t3.small"

  database_username              = "eshop"
  database_port                  = 1433
  database_allocated_storage     = 20
  database_max_allocated_storage = 100

  database_allow_major_version_upgrade = true
  database_storage_encrypted           = false
  database_skip_final_snapshot         = true
  database_create_db_parameter_group   = false

  autoscaling_min_size         = 1
  autoscaling_max_size         = 3
  autoscaling_desired_capacity = 1

  cloudwatch_log_group_name = "/aws/ecs/eshop"

  tags = lookup(local, "tags", null) != null ? merge(local.tags, local.common_tags) : local.common_tags
}
