# ------------------------------------------------------------
# Generate a random suffix
# ------------------------------------------------------------
resource "random_id" "unique" {
  byte_length = 4  # generates an 8-character hex string
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-storage-demo${random_id.unique.hex}" # auto unique"
  location = "East US"
}

# ------------------------------------------------------------
# Storage Account
# ------------------------------------------------------------
resource "azurerm_storage_account" "storage" {
  name                     = "mystorage${random_id.unique.hex}" # auto unique
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
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}
