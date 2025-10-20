variable "location" {
  default = "East US"
}

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
