variable "resource_group_name" {
  default   = "SreeDemo_RG"
  }

variable "location" {
  default   = "East US"
  }
#---------------------------------------------------
# Network Varibles
#-------------------------------------------------------
variable "Vnet_name" {
 default   = "SreeDemo_vnet"
  }

variable "address_space" {
  default   = "10.0.0.0/16"
  }

variable "subnet_names1" {
    default = "DemoWebServer_Subnet"
 }

 variable "subnet_names2" {
    default = "DemoDB_Subnet"
 }

variable "subnet_prefixes1" {
      default  = "10.0.1.0/24"
 }

variable "subnet_prefixes2" {
      default  = "10.0.2.0/24"
 }

variable "PublicIP_name1" {
 default   = "PublicIP_Demowindows"
  }

variable "PublicIP_name2" {
 default   = "PublicIP_DemoLinux"
  }

#-------------------------------------------------------
#NSG
#----------------------------------------------------
variable "NSG_name1" {
 default   = "NSG_DemoLinux"
  }

  variable "NSG_name2" {
 default   = "NSG_Demowindows"
  }
#----------------------------------------------------
#NIC
#----------------------------------------------------

variable "NIC_name1" {
 default   = "NIC1_DemoWindows"
  }

variable "NIC_name2" {
 default   = "NIC1_DemoLinux"
  }

#---------------------------------------------------
#VM Details
#-------------------------------------------------
variable "WindowsVM_name" {
 default   = "Windows_DemoVM"
  }

variable "LinuxVM_name" {
 default   = "Linux_DemoVM"
  }

variable "LinuxVM_Disk_name" {
 default   = "Linux_VM_DemoDisk"
  }
variable "WindowsVM_Disk_name" {
 default   = "Windows_VM_DemoDisk"
  }

variable "Windowscomputer_name" {
 default   = "AZDemoWindows1"
  }

variable "Linuxcomputer_name" {
 default   = "AZDemoLinux1"
  }

variable "admin_username" {
 default   = "azureadmin"
  }
  
variable "admin_password" {
 default   = "Admin@123"
  }