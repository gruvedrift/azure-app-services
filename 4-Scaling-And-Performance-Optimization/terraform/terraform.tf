terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.49.0"
    }
  }
}

# Configure AzureRM provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "8f9aed58-aa08-45bd-960a-2c15d4449132"
}


# Create Resource Group
resource "azurerm_resource_group" "dotnet-rg" {
  location = "West Europe"
  name     = "dotnet-webapp-resource-group"
}

# Create container registry for Docker Images
resource "azurerm_container_registry" "dotnet-cr" {
  location            = azurerm_resource_group.dotnet-rg.location
  name                = "dontetcontainerregistry"
  resource_group_name = azurerm_resource_group.dotnet-rg.name
  sku                 = "Basic"
  admin_enabled       = "true"
}

# Create Windows Service Plan
resource "azurerm_service_plan" "dotnet-service-plan" {
  name                = "dotnet-service-plan"
  location            = azurerm_resource_group.dotnet-rg.location
  resource_group_name = azurerm_resource_group.dotnet-rg.name
  os_type             = "Windows"
  sku_name            = "P0v3" # Could also use Standard tier, but they are legacy
}

# Create Azure Web App
resource "azurerm_windows_web_app" "dotnet-web-app" {
  name                = "dotnet-scaling-demo-application"
  location            = azurerm_resource_group.dotnet-rg.location
  resource_group_name = azurerm_resource_group.dotnet-rg.name
  service_plan_id     = azurerm_service_plan.dotnet-service-plan.id

  # Configure Docker Registry connection
  site_config {

    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v9.0" # Latest .NET version
    }
  }
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = 1 # Run from zip
  }
}

# Create Monitor Autoscale resource. This is where we define our scaling rules
resource "azurerm_monitor_autoscale_setting" "dotnet-autoscale-monitor" {
  name                = "dotnet-autoscale-monitor"
  location            = azurerm_resource_group.dotnet-rg.location
  resource_group_name = azurerm_resource_group.dotnet-rg.name
  target_resource_id  = azurerm_service_plan.dotnet-service-plan.id

  profile {
    name = "CPU-based autoscaling"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.dotnet-service-plan.id
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 70
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT5M"
      }

      scale_action {
        cooldown  = "PT3M"
        direction = "Increase"
        type      = "ChangeCount"
        value     = 2
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.dotnet-service-plan.id
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = 30
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT5M"
      }

      scale_action {
        cooldown  = "PT5M"
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 2
      }
    }
  }

}
