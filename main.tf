#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Create a Linux VM 
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.4.0"

  subscription_id = "528db867-aafd-4420-b517-2e2863ca7305"
  client_id       = "d2ee82e7-0f2a-40e3-ac32-c18f4b46dad3"
  client_secret   = "sZAD2ynOXzJP~4~i6HISVnkB5aKr~k-By6"
  tenant_id       = "8d894c2b-238f-490b-8dd1-d93898c5bf83"

  features {}
}


#
# - Create a Resource Group
#



resource "azurerm_resource_group" "rg" {
    name                  =   "${var.prefix}-rg"
    location              =   var.location
    tags                  =   var.tags
}


#
# - Create a Resource Group Level  restriction
#

resource "azurerm_management_lock" "policy" {
  name       = "${var.prefix}-policy"
  scope      = azurerm_resource_group.rg.id
  lock_level = var.lock_level
}

#
# - Create a Availability Set
#

resource "azurerm_availability_set" "availability_set" {
   name                          = "${var.prefix}-availability_set"
   location                      = azurerm_resource_group.rg.location
   resource_group_name           = azurerm_resource_group.rg.name
   managed                       = var.managed
   platform_fault_domain_count   = var.platform_fault_domain_count

}


#
# - Create a Virtual Network
#

resource "azurerm_virtual_network" "vnet" {
    name                  =   "${var.prefix}-vnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    location              =   azurerm_resource_group.rg.location
    address_space         =   [var.vnet_address_range]
    tags                  =   var.tags
}

#
# - Create a Subnet inside the virtual network
#

resource "azurerm_subnet" "sn" {
    name                  =   "${var.prefix}-sn-subnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    virtual_network_name  =   azurerm_virtual_network.vnet.name
    address_prefixes      =   [var.subnet_address_range]
}

#
# - Create a Network Security Group
#

resource "azurerm_network_security_group" "nsg" {
    name                        =       "${var.prefix}-web-nsg"
    resource_group_name         =       azurerm_resource_group.rg.name
    location                    =       azurerm_resource_group.rg.location
    tags                        =       var.tags

    security_rule {
    name                        =       "Allow_SSH"
    priority                    =       1000
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "Tcp"
    source_port_range           =       "*"
    destination_port_range      =       22
    source_address_prefix       =       "172.17.124.86" 
    destination_address_prefix  =       "*"
    
    }
}


#
# - Subnet-NSG Association
#

resource "azurerm_subnet_network_security_group_association" "subnet-nsg" {
    subnet_id                    =       azurerm_subnet.sn.id
    network_security_group_id    =       azurerm_network_security_group.nsg.id
}


#
# - Public IP (To Login to Linux VM)
#

resource "azurerm_public_ip" "pip" {
    name                            =     "${var.prefix}-linuxvm-public-ip"
    resource_group_name             =     azurerm_resource_group.rg.name
    location                        =     azurerm_resource_group.rg.location
    allocation_method               =     var.allocation_method[0]
    tags                            =     var.tags
}


#
# - Create a Random string to append to Storage account name
#

resource "random_string" "sa_name" {
   length   =   5
   special  =   false
   lower    =   true
   upper    =   false
   number   =   false
}

#
# - Create a Storage account with Network Rules
#

resource "azurerm_storage_account" "sa" {
    count                         =    var.saCount
    name                          =    "sa${random_string.sa_name.result}${count.index+1}"
    resource_group_name           =    azurerm_resource_group.rg.name
    location                      =    azurerm_resource_group.rg.location
    account_tier                  =    var.saVars["account_tier"]
    account_replication_type      =    var.saVars["account_replication_type"]
}



#
# - Create a Network Interface Card for Virtual Machine
#

resource "azurerm_network_interface" "nic" {
    name                              =   "${var.prefix}-linuxvm-nic"
    resource_group_name               =   azurerm_resource_group.rg.name
    location                          =   azurerm_resource_group.rg.location
    tags                              =   var.tags
    ip_configuration                  {
        name                          =  "${var.prefix}-nic-ipconfig"
        subnet_id                     =   azurerm_subnet.sn.id
        public_ip_address_id          =   azurerm_public_ip.pip.id
        private_ip_address_allocation =   var.allocation_method[1]
    }
}


#
# - Create a Linux Virtual Machine
# 

resource "azurerm_linux_virtual_machine" "vm" {
    name                              =   "${var.prefix}-linuxvm"
    resource_group_name               =   azurerm_resource_group.rg.name
    location                          =   azurerm_resource_group.rg.location
    network_interface_ids             =   [azurerm_network_interface.nic.id]
    size                              =   var.virtual_machine_size
    computer_name                     =   var.computer_name
    admin_username                    =   var.admin_username
    admin_password                    =   var.admin_password
    disable_password_authentication   =   false

    os_disk  {
        name                          =   "${var.prefix}-linuxvm-os-disk"
        caching                       =   var.os_disk_caching
        storage_account_type          =   var.os_disk_storage_account_type
        disk_size_gb                  =   var.os_disk_size_gb
    }

    source_image_reference {
        publisher                     =   var.publisher
        offer                         =   var.offer
        sku                           =   var.sku
        version                       =   var.vm_image_version
    }

    tags                              =   var.tags

}
