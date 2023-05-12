include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/azure-container-environment"

  common_tags = {
    Environment = "dev"
  }
}

inputs = {
  vnet_name           = "eshop-vpc"
  resource_group_name = include.root.locals.resource_group_name
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/26", "10.0.2.0/24", "10.0.3.0/24"]
  location            = include.root.locals.location

  sqlserver_name               = "eshop"
  database_name                = "eshop"

}
