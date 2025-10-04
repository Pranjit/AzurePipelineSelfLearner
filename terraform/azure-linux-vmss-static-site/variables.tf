variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "html_repo_url" {
  description = "GitHub repo with static HTML files"
  type        = string
}
