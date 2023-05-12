resource "azurerm_container_app" "example" {
  name                         = "example-app"
  container_app_environment_id = data.azurerm_container_app_environment.this.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}

data "azurerm_container_app_environment" "this" {
  name                = "example-environment"
  resource_group_name = "example-resources"
}
