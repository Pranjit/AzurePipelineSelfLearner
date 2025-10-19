# Input variables
variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "client_id" {
  type        = string
  description = "Azure service principal client ID"
}

variable "client_secret" {
  type        = string
  description = "Azure service principal client secret"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "rg-demo-terraform"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "East US"
}

variable "environment" {
  type        = string
  description = "Environment tag"
  default     = "dev"
}
