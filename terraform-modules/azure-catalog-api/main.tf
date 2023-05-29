locals {
  tags = {
    "environment" = "dev"
  }
}
terraform {
  required_version = ">= 0.13.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.54.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "eshop-rg" {
  name     = "${var.service}-resource-group"
  location = "West Europe"
  tags     = local.tags
}

resource "azurerm_log_analytics_workspace" "eshop-la" {
  name                = "${var.service}-log-analytics"
  location            = azurerm_resource_group.eshop-rg.location
  resource_group_name = azurerm_resource_group.eshop-rg.name
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_container_app_environment" "eshop-cae" {
  name                       = "${var.service}-container-environment"
  location                   = azurerm_resource_group.eshop-rg.location
  resource_group_name        = azurerm_resource_group.eshop-rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.eshop-la.id
  tags                       = local.tags
}

resource "azurerm_container_app" "eshop-ca" {
  name                         = "${var.service}-container-app"
  container_app_environment_id = azurerm_container_app_environment.eshop-cae.id
  resource_group_name          = azurerm_resource_group.eshop-rg.name
  revision_mode                = "Single"
  tags                         = local.tags

  template {
    container {
      name   = var.service
      image  = var.image
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
 
  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 80
    traffic_weight {
      percentage = 100
    }
  }
}
