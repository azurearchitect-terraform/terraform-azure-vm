provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "azurerm_resource_group" "rg" {
    name = "1-b3e45e5a-playground-sandbox"
    location = "South Central US"
}


resource "azurerm_virtual_network" "vnet" {
    name = "myvnet"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "SubnetA" {
    name = "SubnetA"
    address_prefixes = ["10.0.1.0/24"]
    virtual_network_name = azurerm_virtual_network.vnet.name
    resource_group_name = azurerm_resource_group.rg.name  
}

resource "azurerm_subnet" "SubnetB" {
    name = "SubnetB"
    address_prefixes = ["10.0.2.0/24"]
    virtual_network_name = azurerm_virtual_network.vnet.name
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "SubnetC" {
  name = "SubnetC"
  address_prefixes = ["10.0.3.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "SubnetD" {
    name = "SubnetD"
    address_prefixes = ["10.0.4.0/24"]
    virtual_network_name = azurerm_virtual_network.vnet.name
    resource_group_name = azurerm_resource_group.rg.name  
}

resource "azurerm_public_ip" "lb_public_ip" {
    name = "lbpubip01"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"      
}

resource "azurerm_lb" "lb" {
    name = "myLoadBalancer"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location  
frontend_ip_configuration {
        name = "myFrontEnd"
        public_ip_address_id = azurerm_public_ip.lb_public_ip.id
    }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
    name = "MyBackendPool"
    loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lb_probe" {
    loadbalancer_id = azurerm_lb.lb.id
    name ="httpProbe"
    port = 80
}

resource "azurerm_lb_rule" "lb_rule" {
    loadbalancer_id = azurerm_lb.lb.id
    name = "httpRule"
    frontend_port = 80
    backend_port = 80
    protocol = "Tcp" 
    frontend_ip_configuration_name = "myFrontEnd"  
}

resource "azurerm_network_interface" "nic1" {
    name = "nic1"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.SubnetA.id
      private_ip_address_allocation = "Dynamic"      
    }
  
}

resource "azurerm_network_interface" "nic2" {
    name = "nic2"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.SubnetB.id
        private_ip_address_allocation = "Dynamic"
      
    }
    }  

    resource "azurerm_network_interface" "nic3" {
        name = "nic3"
        resource_group_name = azurerm_resource_group.rg.name
        location = azurerm_resource_group.rg.location
        ip_configuration {
          name = "internal"
          subnet_id = azurerm_subnet.SubnetC.id
          private_ip_address_allocation = "Dynamic"
        }
    }

    resource "azurerm_network_interface" "nic4" {
        name = "nic4"
        resource_group_name = azurerm_resource_group.rg.name
        location = azurerm_resource_group.rg.location
        ip_configuration {
          name = "internal"
          subnet_id = azurerm_subnet.SubnetD.id
          private_ip_address_allocation = "Dynamic"
        }
     }

     resource "azurerm_windows_virtual_machine" "vm1" {
  name                  = "vm1"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "Password1234!"
  os_disk {
    name              = "osdisk3"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  custom_data = base64encode(file("C:/Terraform/azure-vm-lb/scripts/setup-vm3.ps1"))
}

resource "azurerm_windows_virtual_machine" "vm2" {
        name = "vm2"
        location = azurerm_resource_group.rg.location
        resource_group_name = azurerm_resource_group.rg.name
        size = "Standard_B1s"
        network_interface_ids = [azurerm_network_interface.nic2.id]
        admin_username = "harnish"
        admin_password = "H@rn!$h@1612"
        os_disk {
            name = "osdisk1"
            caching = "ReadWrite"
            storage_account_type = "Standard_LRS"
        }

        source_image_reference {
          publisher = "MicrosoftwindowsServer"
          offer = "WindowsServer"
          sku= "2019-Datacenter"
          version = "latest"
        }
        # custom_data = base64encode(file("C:/Terraform/azure-vm-lb/scripts/setup-vm1.ps1"))
    }

resource "azurerm_windows_virtual_machine" "vm3" {
  name                  = "vm3"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic3.id]
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "Password1234!"
  os_disk {
    name              = "osdisk4"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  custom_data = base64encode(file("C:/Terraform/azure-vm-lb/scripts/setup-vm3.ps1"))
}

resource "azurerm_windows_virtual_machine" "vm4" {
  name                  = "vm4"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic4.id]
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "Password1234!"
  os_disk {
    name              = "osdisk5"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  custom_data = base64encode(file("C:/Terraform/azure-vm-lb/scripts/setup-vm3.ps1"))
}






