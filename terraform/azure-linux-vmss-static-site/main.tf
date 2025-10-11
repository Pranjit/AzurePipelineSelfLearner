resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${var.build_id}"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name 
  depends_on          = [azurerm_resource_group.rg] 
}

resource "azurerm_subnet" "subnet" {
  name                 = "vmss-subnet"
  resource_group_name  = azurerm_resource_group.rg.name 
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on          = [azurerm_resource_group.rg] 
}

resource "azurerm_public_ip" "pip" {
  name                = "vmss-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.rg] 
}

resource "azurerm_lb" "lb" {
  name                = "vmss-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIP"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  name                = "BackendPool"
  loadbalancer_id     = azurerm_lb.lb.id  
}

resource "azurerm_lb_probe" "http" {
  name                = "http-probe"  
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
}

resource "azurerm_lb_rule" "http" {
  name                           = "http-rule"  
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIP"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.http.id
}
# Define the Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "lb-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Define an inbound rule for HTTP traffic on port 80
resource "azurerm_network_security_rule" "http_inbound" {
  name                        = "allow-http-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Associate the NSG with your subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "web-vmss"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg.name
  sku                             = "Standard_B1s"
  instances                       = 2
  admin_username                  = "azureuser"
  admin_password                  = "P@ssword1234!"
  disable_password_authentication = false
  upgrade_mode                    = "Manual"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
    }
  }

  extension {
    name                 = "install-nginx-html"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = jsonencode({
      "commandToExecute" = <<-EOF
        #!/bin/bash
        apt update -y && apt install -y git nginx curl
        # Create working directory
        mkdir -p /var/www/html
        cd /var/www/html
    
        # Initialize empty Git repo
        git init
        git remote add origin https://github.com/Pranjit/AzurePipelineSelfLearner.git
    
        # Enable sparse checkout (so we can fetch only a subfolder)
        git config core.sparseCheckout true
    
        # Specify the folder you want from repo (relative path)
        echo "SampleWebSites/StaticWeb/" >> .git/info/sparse-checkout
    
        # Pull from main branch (change if branch name is different)
        git pull origin main
    
        # Restart Nginx
        systemctl enable nginx
        systemctl restart nginx
      EOF
    })
  }
}
