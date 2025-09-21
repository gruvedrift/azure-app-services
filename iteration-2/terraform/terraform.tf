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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

  }
  subscription_id = "8f9aed58-aa08-45bd-960a-2c15d4449132"
}

# Create Resource Group
resource "azurerm_resource_group" "tiny-flask-rg" {
  name     = "tiny-flask-resource-group"
  location = "West Europe"
}

# Create Container Registry for Docker image
resource "azurerm_container_registry" "tiny-flask-cr" {
  name                = "tinyflaskcontainerregistry"
  location            = azurerm_resource_group.tiny-flask-rg.location
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  sku                 = "Basic"
  admin_enabled       = "true"
}

# Create Azure Service Plan
resource "azurerm_service_plan" "tiny-flask-asp" {
  name                = "tiny-flask-service-plan"
  location            = azurerm_resource_group.tiny-flask-rg.location
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create Azure Log Analytics Workspace.

resource "azurerm_log_analytics_workspace" "tiny-flask-aws" {
  name                = "tiny-flask-log-analytics-workspace"
  location            = azurerm_resource_group.tiny-flask-rg.location
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30 # Lowest possible, can retain up to 730 days ~ little over 2 years
}

# Create Application Insights
resource "azurerm_application_insights" "tiny-flask-ai" {
  name                = "tiny-flask-app-insights"
  location            = azurerm_resource_group.tiny-flask-rg.location
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.tiny-flask-aws.id
}

# Create Azure Web App
resource "azurerm_linux_web_app" "tiny-flask" {
  location            = azurerm_resource_group.tiny-flask-rg.location
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  name                = "tiny-flask-web-app"
  service_plan_id     = azurerm_service_plan.tiny-flask-asp.id

  site_config {
    application_stack {
      docker_registry_username = azurerm_container_registry.tiny-flask-cr.admin_username
      docker_registry_password = azurerm_container_registry.tiny-flask-cr.admin_password
      docker_image_name        = "tiny-flask-monitoring:latest"
      docker_registry_url      = "https://${azurerm_container_registry.tiny-flask-cr.login_server}"
    }
  }
  # Connect to Application Insights
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.tiny-flask-ai.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  }
}
