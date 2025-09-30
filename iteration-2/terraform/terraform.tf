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

# Create Action Group
resource "azurerm_monitor_action_group" "tiny-flask-ag" {
  name                = "tiny-flask-action-group"
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  short_name          = "tinyflask"

  email_receiver {
    name          = "gruvedrift-admin-email"
    email_address = "william.gruvedrift@gmail.com"
  }

  sms_receiver {
    name         = "gruvedrift-sms-alert"
    country_code = "47"
    phone_number = "90625625"
  }
}

# Create Metric Alert Rule ( threshold-based )
resource "azurerm_monitor_metric_alert" "high-cpu" {
  name                = "high-cpu-consumption-alert"
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  scopes              = [azurerm_service_plan.tiny-flask-asp.id]
  # Scope are a set of resource IDs at which the metric criteria should be applied. CPU percentage is emitted at App Service Plan.
  description = "Alert when CPU usage is above 70%"

  criteria {
    aggregation      = "Average"
    metric_name      = "CpuPercentage"
    metric_namespace = "Microsoft.Web/serverfarms" # metrics namespace to be monitored
    operator         = "GreaterThan"
    threshold        = 70
  }

  severity    = 2
  window_size = "PT5M" # The period of time that is used to monitor alert activity. Default is PT5M
  frequency   = "PT1M" # The evaluation frequency of this Metric Alert

  action {
    action_group_id = azurerm_monitor_action_group.tiny-flask-ag.id
  }
}

# Create Log Query Alert Rule ( log-based / pattern-based )
resource "azurerm_monitor_scheduled_query_rules_alert" "error-spike" {
  name                = "error-spike-alert"
  resource_group_name = azurerm_resource_group.tiny-flask-rg.name
  location            = azurerm_resource_group.tiny-flask-rg.location
  data_source_id      = azurerm_log_analytics_workspace.tiny-flask-aws.id
  # The resource URI over which log search query is to be run.
  description         = "Alert when more than 10 errors occur within a 1 minute bucket"

  query = <<-KQL
      AppTraces
    | where Message contains "Simulated error"
    | summarize ErrorCount = count() by bin(TimeGenerated, 1m)
  KQL
  trigger {
    operator  = "GreaterThan"
    threshold = 10
  }

  severity    = 2
  frequency   = 5 # Schedule for evaluation, run every 5 minute.
  time_window = 5 # Scope of the data analyzed, Look back 5 minutes.

  action {
    action_group = [azurerm_monitor_action_group.tiny-flask-ag.id]
  }
}
