# 1️⃣ Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "demo-func-rg"
  location = "East US"
}

# 2️⃣ Storage Account (required for Function)
resource "azurerm_storage_account" "sa" {
  name                     = "funcstor${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# 3️⃣ App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = "demo-func-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption plan
}

# 4️⃣ Function App
resource "azurerm_linux_function_app" "function" {
  name                = "demo-function-app-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key  = azurerm_storage_account.sa.primary_access_key
  functions_extension_version = "~4"

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    AzureWebJobsStorage      = azurerm_storage_account.sa.primary_connection_string
  }
}
