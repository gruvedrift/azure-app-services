# Azure provider for configuring infrastructure in Microsoft Azure, using the Azure Resource Manager APIs.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.0.0"
    }
  }
}

# Configure AzureRM provider
provider "azurerm" {
  # The features block allows for changing the behaviour of the AzureRM.
  features {}
  subscription_id = "8f9aed58-aa08-45bd-960a-2c15d4449132"
}

# Create Resource Group
resource "azurerm_resource_group" "tiny-flask" {
  name     = "tiny-flask-resource-group"
  location = "West Europe"
}

# Create App Service Plan
resource "azurerm_service_plan" "tiny-flask" {
  location            = azurerm_resource_group.tiny-flask.location
  name                = "tiny-flask-asp"
  resource_group_name = azurerm_resource_group.tiny-flask.name
  os_type             = "Linux"
  sku_name            = "B1"
}


# Create Postgres Flexible Database Server
resource "azurerm_postgresql_flexible_server" "tiny-flask" {
  name                          = "tiny-flask-flexi-db-server"
  resource_group_name           = azurerm_resource_group.tiny-flask.name
  location                      = "North Europe"
  version                       = "13"
  public_network_access_enabled = true # Simple for demonstration
  administrator_login           = "SandwormRyder666"
  administrator_password        = "SardaukarKiller666"
  sku_name                      = "B_Standard_B2ms"
  zone                          = "1"
}

# Create Postgres Flexible Database
resource "azurerm_postgresql_flexible_server_database" "tiny-flask" {
  name      = "tiny-flask-flexi-db"
  server_id = azurerm_postgresql_flexible_server.tiny-flask.id
  collation = "en_US.utf8"
  charset   = "UTF8"
  lifecycle {
    prevent_destroy = false # Don't care about data
  }
}

# Add Firewall rule for connecting from local machine.
# Warning! Open for all traffic, should never allow all access in production or if storing sensitive data.
resource "azurerm_postgresql_flexible_server_firewall_rule" "tiny-flask" {
  name             = "tiny-flask-firewall-rule"
  server_id        = azurerm_postgresql_flexible_server.tiny-flask.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

# Create a Web App
resource "azurerm_linux_web_app" "tiny-flask" {
  location            = azurerm_resource_group.tiny-flask.location
  resource_group_name = azurerm_resource_group.tiny-flask.name
  name                = "tiny-flask-web-app"
  service_plan_id     = azurerm_service_plan.tiny-flask.id

  site_config {
    application_stack {
      python_version = "3.10"
    }

    app_command_line = "gunicorn --bind 0.0.0.0:8000 --timeout 600 app:web_app"
    # App Services runs behind a reverse proxy that expects the application to listen to a specific port.
    always_on = true

  }
  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true" # Build dependencies during deployment
    "WEBSITES_PORT"                  = "8000" # This tells App Service which port Gunicorn uses

    # Inject Postgres connection details
    "DB_HOST"     = azurerm_postgresql_flexible_server.tiny-flask.fqdn
    "DB_NAME"     = azurerm_postgresql_flexible_server_database.tiny-flask.name
    "DB_USER"     = azurerm_postgresql_flexible_server.tiny-flask.administrator_login
    "DB_PASSWORD" = azurerm_postgresql_flexible_server.tiny-flask.administrator_password
  }
}