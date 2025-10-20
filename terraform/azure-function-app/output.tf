output "function_app_name" {
  value = azurerm_linux_function_app.function.name
}

output "function_app_url" {
  value = "https://${azurerm_linux_function_app.function.default_hostname}"
}
