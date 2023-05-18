resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

################################################################################
# VNET
# https://github.com/Azure/terraform-azurerm-vnet/blob/main/variables.tf
################################################################################

module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.0.0"

  vnet_name           = var.vnet_name
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  use_for_each        = var.use_for_each
  vnet_location       = var.location

  tags = var.tags
}

################################################################################
# MSSQL SERVER
# https://github.com/kumarvna/terraform-azurerm-mssql-db/blob/master/variables.tf
################################################################################

module "mssql-server" {
  source  = "kumarvna/mssql-db/azurerm"
  version = "1.3.0"

  create_resource_group = false
  resource_group_name   = var.resource_group_name
  location              = var.location

  sqlserver_name               = var.sqlserver_name
  database_name                = var.database_name
  sql_database_edition         = var.sql_database_edition
  sqldb_service_objective_name = var.sqldb_service_objective_name

  # SQL server extended auditing policy defaults to `true`. 
  # To turn off set enable_sql_server_extended_auditing_policy to `false`  
  # DB extended auditing policy defaults to `false`. 
  # to tun on set the variable `enable_database_extended_auditing_policy` to `true` 
  # To enable Azure Defender for database set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = true
  log_retention_days             = 30

  enable_vulnerability_assessment = false
  //email_addresses_for_alerts      = ["user@example.com", "firstname.lastname@example.com"]

  enable_private_endpoint = true
  existing_vnet_id        = module.vnet.vnet_id
  existing_subnet_id      = lookup(module.vnet.vnet_subnets_name_id, "subnet1")

  # AD administrator for an Azure SQL server
  # Allows you to set a user or group as the AD administrator for an Azure SQL server
  ad_admin_login_name = "firstname.lastname@example.com"

  #   enable_log_monitoring      = true
  #   log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id

  # Firewall Rules to allow azure and external clients and specific Ip address/ranges. 
  enable_firewall_rules = true
  firewall_rules = [
    {
      name             = "access-to-azure"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  ]

  depends_on = [azurerm_resource_group.this, module.vnet]

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "acctest-01"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 1
}

resource "azurerm_container_app_environment" "this" {
  name                       = "eshop"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}
