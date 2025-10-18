terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.0.0"
    }
  }
}

# AzureRM provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "8f9aed58-aa08-45bd-960a-2c15d4449132"
}

# Create Resource Group
resource "azurerm_resource_group" "tiny-flask-rg" {
  location = "West Europe"
  name     = "tiny-flask-resource-group"
}

# Create Container Registry for Docker Images
resource "azurerm_container_registry" "tiny-flask-cr" {
  name                = "tinyflaskcontainerregistry"
  location            = azurerm_resource_group.tiny-flask-rg.location
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  sku                 = "Basic"
  admin_enabled       = "true"
}

# Create Azure Service Plan
resource "azurerm_service_plan" "tiny-flask-service-plan" {
  name                = "tiny-flask-service-plan"
  location            = azurerm_resource_group.tiny-flask-rg.location
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  os_type             = "Linux"
  sku_name            = "P0v3"
}

# Create Azure Web App
resource "azurerm_linux_web_app" "tiny-flask-app" {
  location            = azurerm_resource_group.tiny-flask-rg.location
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  name                = "tiny-flask-web-app"
  service_plan_id     = azurerm_service_plan.tiny-flask-service-plan.id

  # Configure Docker Registry connection
  site_config {
    application_stack {
      docker_registry_username = azurerm_container_registry.tiny-flask-cr.admin_username
      docker_registry_password = azurerm_container_registry.tiny-flask-cr.admin_password
      docker_registry_url      = "https://${azurerm_container_registry.tiny-flask-cr.login_server}"
      docker_image_name        = "tiny-flask-web-app:v1.0"
    }
  }
  app_settings = {
    # Slot specific environment variables
    APPLICATION_VERSION = "v1.0"
    ENVIRONMENT         = "PRODUCTION"
    DATABASE_CONNECTION = "PROD-DB-STRING"
  }
  sticky_settings {
    app_setting_names = ["ENVIRONMENT", "DATABASE_CONNECTION"]
  }
}

# Create Staging Slot
resource "azurerm_linux_web_app_slot" "tiny-flask-staging-slot" {
  name           = "tiny-flask-staging-slot"
  app_service_id = azurerm_linux_web_app.tiny-flask-app.id

  site_config {
    application_stack {
      docker_registry_username = azurerm_container_registry.tiny-flask-cr.admin_username
      docker_registry_password = azurerm_container_registry.tiny-flask-cr.admin_password
      docker_registry_url      = "https://${azurerm_container_registry.tiny-flask-cr.login_server}"
      docker_image_name        = "tiny-flask-web-app:v1.0"
    }
  }

  app_settings = {
    # Slot specific environment variables
    APPLICATION_VERSION = "v1.0"
    ENVIRONMENT         = "STAGING"
    DATABASE_CONNECTION = "STAGING-DB-STRING"
  }
}
