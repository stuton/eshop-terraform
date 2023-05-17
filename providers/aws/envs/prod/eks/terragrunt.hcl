include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-eks"
}

inputs = {
  name        = "eshop"
  description = "EKS for eshop application"
  cluster_endpoint_public_access = true
  cluster_ip_family = "ipv6"
  create_cni_ipv6_iam_policy = true
}
