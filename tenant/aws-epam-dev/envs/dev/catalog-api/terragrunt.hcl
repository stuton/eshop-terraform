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

  mock_outputs = {
    cluster_id = "fake-cluster_id"
    vpc_id = "fake-vpc_id"
    public_subnets = ["fake-public_subnet"]
    lb_id = "arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:fake"
  }
}

inputs = {
  name   = "catalog-api"
  cluster_id = dependency.ecs.outputs.cluster_id
  vpc_id = dependency.ecs.outputs.vpc_id
  public_subnets = dependency.ecs.outputs.public_subnets
  lb_id = dependency.ecs.outputs.lb_id
  container_definitions = templatefile("${path.module}/container_definitions.json", {
    container_name = "catalog-api"
    image = "winshiftq/catalog.api:linux-terraform"
    connection_string = format("Server=%s,5433;Database=Microsoft.eShopOnContainers.Service.CatalogDb;User Id=sa;Password=%s", dependency.ecs.outputs.database_host, dependency.ecs.outputs.database_password)
  })
}
