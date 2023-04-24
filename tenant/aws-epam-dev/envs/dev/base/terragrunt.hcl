include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-ecs"

  common_tags = {
    Environment="dev"
  }
}

inputs = {
  app_name       = "eshop"
  vpc_cidr       = "10.0.0.0/16"
  
  create_mq      = false
  mq_engine_type = "RabbitMQ"
  mq_engine_version = "3.11.13"

  create_database_instance = true
  database_instance_name = "eshop"
  database_engine               = "sqlserver-ex"
  database_engine_version       = "15.00"
  database_family               = "sqlserver-ex-15.0"
  database_major_engine_version = "15.00"
  database_instance_class       = "db.t2.micro"
  database_username = "eshop"
  
  database_port                  = 1433
  database_allocated_storage     = 20
  database_max_allocated_storage = 100

  database_storage_encrypted         = false
  database_skip_final_snapshot       = true
  database_create_db_parameter_group = false

  tags           = lookup(local, "tags", null) != null ? merge(local.tags, local.common_tags) : local.common_tags
}
