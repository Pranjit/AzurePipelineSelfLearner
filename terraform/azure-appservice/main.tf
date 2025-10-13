terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-appservice-demo"
  location = "East US"
}

# Create App Service Plan (Linux)
resource "azurerm_service_plan" "plan" {
  name                = "asp-demo-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1" # Basic Tier
}

# Create App Service (Web App)
resource "azurerm_linux_web_app" "webapp" {
  name                = "my-demo-webapp-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "ENVIRONMENT"              = "production"
  }
}

# Random suffix for unique name
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}
