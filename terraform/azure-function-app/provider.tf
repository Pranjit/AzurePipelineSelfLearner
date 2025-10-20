terraform {
  required_providers {
      azurerem = {
        source  = "hashicorp/azurerm"
        version = "~> 4.0"
      }
  }
  required_version = ">= 1.5.0"
}
 provider "azurerem" {
      features {}
      # Uses Azure DevOps Service Connection
      subscription_id = var.subscription_id
      client_id       = var.client_id
      client_secret   = var.client_secret
      tenant_id       = var.tenant_id
 }
