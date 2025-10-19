resource "azurerm_resource_group" "rg" {
  name     = "rg-storage-demo"
  location = "East US"
}

# ------------------------------------------------------------
# Storage Account
# ------------------------------------------------------------
resource "azurerm_storage_account" "storage" {
  name                     = "mystorageacctdemo123"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = {
    environment = "demo"
  }
}

# ------------------------------------------------------------
# Storage Container (optional)
# ------------------------------------------------------------
resource "azurerm_storage_container" "container" {
  name                  = "appfiles"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
