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

resource "azurerm_servicebus_namespace" "eshop-sb" {
  name                = "${var.service}-servicebus"
  location            = azurerm_resource_group.eshop-rg.location
  resource_group_name = azurerm_resource_group.eshop-rg.name
  sku                 = "Standard"

  tags = {
    source = "terraform"
  }
}
