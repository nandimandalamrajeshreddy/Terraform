#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Linux VM - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

# Prefix and Tags

variable "prefix" {
    description =   "Prefix to append to all resource names"
    type        =   string
    default     =   "dryrun"
}

variable "tags" {
    description =   "Resouce tags"
    type        =   map(string)
    default     =   {
        "author"        =   "Rajesh"
        "deployed_with" =   "Terraform"
    }
}

# Resource Group

variable "location" {
    description =   "Location of the resource group"
    type        =   string
    default     =   "East US"
}

# Resource Group Level  restriction

variable "lock_level" {
    description =   "Items can't be deleted in this subscription!"
    type        =   string
    default     =   "CanNotDelete"
}

# Availability Set

variable "managed" {
    type    =   string
    default =   true
}

variable "platform_fault_domain_count" {
    type    =   string
    default =   2
}

# Vnet and Subnet

variable "vnet_address_range" {
    description =   "IP Range of the virtual network"
    type        =   string
    default     =   "10.0.0.0/16"
}

variable "subnet_address_range" {
    description =   "IP Range of the virtual network"
    type        =   string
    default     =   "10.0.1.0/24"
}

# Public IP and NIC Allocation Method

variable "allocation_method" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   string
    default     =   "Dynamic"
}


# Storage 

variable "saCount" {
    default     =   2
}

variable "account_tier" {
    description  =  "Variables for Storage accounts and containers"
    type         =  string
    default      =  "Standard"
       
}


    
variable "account_replication_type" {
    description  =  "Variables for Storage accounts and containers"
    type         =  string
    default      =  "LRS"
      
}

    



# VM 

variable "virtual_machine_size" {
    description =   "Size of the VM"
    type        =   string
    default     =   "Standard_B1s"
}

variable "computer_name" {
    description =   "Computer name"
    type        =   string
    default     =   "Linuxvm"
}

variable "admin_username" {
    description =   "Username to login to the VM"
    type        =   string
    default     =   "linuxadmin"
}

variable "admin_password" {
    description =   "Password to login to the VM"
    type        =   string
    default     =   "Unisys@2020$*"
}

variable "os_disk_caching" {
    default     =       "ReadWrite"
}

variable "os_disk_storage_account_type" {
    default     =       "StandardSSD_LRS"
}

variable "os_disk_size_gb" {
    default     =       64
}

variable "publisher" {
    default     =       "Canonical"
}

variable "offer" {
    default     =       "UbuntuServer"
}

variable "sku" {
    default     =       "16.04-LTS"
}

variable "vm_image_version" {
    default     =       "latest"
}
