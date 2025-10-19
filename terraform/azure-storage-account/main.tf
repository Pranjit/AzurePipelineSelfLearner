resource "azurerm_resource_group" "rg" {
  name     = "rg-storage-demo"
  location = "East US"
}

# ------------------------------------------------------------
# Storage Account
# ------------------------------------------------------------
resource "azurerm_storage_account" "storage" {
  name                     = "mystorageacctdemo123"   # must be globally unique, lowercase, 3–24 chars
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"               # Standard or Premium
  account_replication_type = "LRS"                    # LRS, GRS, RAGRS, ZRS

  # Optional: enable public access or features
  allow_blob_public_access = false

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
