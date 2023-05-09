include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/azure-container-apps"

  common_tags = {
    Environment="dev"
  }
}
