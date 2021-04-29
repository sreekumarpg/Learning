
# Azure Provider source and version being used
terraform {
    backend "azurerm" {
    resource_group_name   = "StorageAccount_terraform"
    storage_account_name  = "sreeterraformstate"
    container_name        = "tstate"
    key                   = "2viMfF3z+XCHs5prQ3ijpGfBNWQdb7e/CB5SfBol75py5PB2yYP9CvPCpyF9/Bjwwq6Gyl0JU8HcEZMtu1W0+Q=="
}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.56.0"
    }
  }
}



# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

##----------------------------------------------------------------
#Create Azure Resource Group
#-------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}
##----------------------------------------------------------------
#Create Azure Virtual Network
#----------------------------------------
resource "azurerm_virtual_network" "Vnet" {
  name                = "${var.Vnet_name}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space       = ["${var.address_space}"]

}
##----------------------------------------------------------------
#Create Azure Subnet in Virtual Network
#-------------------------------------------
resource "azurerm_subnet" "subnet1" {
    name = "${var.subnet_names1}"
    virtual_network_name = "${azurerm_virtual_network.Vnet.name}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    address_prefixes = ["${var.subnet_prefixes1}"]
  
}
resource "azurerm_subnet" "subnet2" {
    name = "${var.subnet_names2}"
    virtual_network_name = "${azurerm_virtual_network.Vnet.name}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    address_prefixes = ["${var.subnet_prefixes2}"]
  
}
##----------------------------------------------------------------
# Create public IPs
#-------------------------------------------

resource "azurerm_public_ip" "DemopublicipWindows" {
    name                         = "${var.PublicIP_name1}"
    location                     = "${azurerm_resource_group.rg.location}"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    allocation_method            = "Dynamic"

    }
resource "azurerm_public_ip" "DemopublicipLinux" {
    name                         = "${var.PublicIP_name2}"
    location                     = "${azurerm_resource_group.rg.location}"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    allocation_method            = "Dynamic"

    }

##----------------------------------------------------------------
# Create NSG for Public IPs
#-------------------------------------------
resource "azurerm_network_security_group" "demonsgLinux" {
    name                = "${var.NSG_name1}"
    location            = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
}
}
resource "azurerm_network_security_group" "demonsgWindows" {
    name                = "${var.NSG_name2}"
    location            = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    security_rule {
        name                       = "HTTP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
}
    security_rule {
        name                       = "RDP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
}
}
##----------------------------------------------------------------
# Create virtual network interface card
#-------------------------------------------
resource "azurerm_network_interface" "DemonicWindows" {
    name                        = "${var.NIC_name1}"
    location                    = "${azurerm_resource_group.rg.location}"
    resource_group_name         = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name                          = "WindowsNicConfiguration"
        subnet_id                     = azurerm_subnet.subnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.DemopublicipWindows.id
    }
}

resource "azurerm_network_interface" "DemonicLinux" {
    name                        = "${var.NIC_name2}"
    location                    = "${azurerm_resource_group.rg.location}"
    resource_group_name         = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name                          = "LinuxNicConfiguration"
        subnet_id                     = azurerm_subnet.subnet2.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.DemopublicipLinux.id
    }
}
##----------------------------------------------------------------
# Connect the security group to the network interface
#-------------------------------------------
resource "azurerm_network_interface_security_group_association" "nic_sgaWindows" {
    network_interface_id      = azurerm_network_interface.DemonicWindows.id
    network_security_group_id = azurerm_network_security_group.demonsgWindows.id
}  

resource "azurerm_network_interface_security_group_association" "nic_sgaLinux" {
    network_interface_id      = azurerm_network_interface.DemonicLinux.id
    network_security_group_id = azurerm_network_security_group.demonsgLinux.id
} 

##----------------------------------------------------------------
# Create virtual machine
#-------------------------------------------

resource "azurerm_linux_virtual_machine" "LinuxVM" {
    name                  = "${var.LinuxVM_name}"
    location              = "${azurerm_resource_group.rg.location}"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids =  [azurerm_network_interface.DemonicLinux.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              =  "${var.LinuxVM_Disk_name}"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "${var.Linuxcomputer_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    disable_password_authentication = false

   }

   ##----------------------------------------------------------------
# Create Windows virtual machine
#-------------------------------------------

resource "azurerm_windows_virtual_machine" "Windowsvm" {
    name                  = "${var.WindowsVM_name}"
    location              = "${azurerm_resource_group.rg.location}"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids =  [azurerm_network_interface.DemonicWindows.id]
    size                  = "Standard_F2"

    os_disk {
        name              =  "${var.WindowsVM_Disk_name}"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2016-Datacenter"
        version   = "latest"
    }

    computer_name  = "${var.Windowscomputer_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
      
   }
   resource "azurerm_virtual_machine_extension" "vm_extension_install_IIS2" {
  name                       = "vm_extension_install_IIS2"
  virtual_machine_id         = azurerm_windows_virtual_machine.Windowsvm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
          "fileUris": ["https://sreeterraformstate.blob.core.windows.net/script/iis.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file iis.ps1" 
            
      }
 SETTINGS
  }
