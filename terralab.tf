# TODO
# check resource dependencies
#

variable "resourcename" {
  default = "myResourceGroup"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "West Europe"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myterraVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "West Europe"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "myterrasubnet"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "West Europe"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "West Europe"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

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

    tags {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "vm1nic" {
    name                      = "vm1nic"
    location                  = "West Europe"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "vm1NicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "vm2nic" {
    name                      = "vm2nic"
    location                  = "West Europe"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
    }

    tags {
        environment = "Terraform Demo"
    }
}
resource "azurerm_storage_account" "myterraformstorageacc" {
  name                     = "myterraformaccount"
  resource_group_name      = "${azurerm_resource_group.myterraformgroup.name}"
  location                 = "${azurerm_resource_group.myterraformgroup.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_storage_container" "myterraformstoragecontainer" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
  storage_account_name  = "${azurerm_storage_account.myterraformstorageacc.name}"
  container_access_type = "private"
  depends_on = ["azurerm_storage_account.myterraformstorageacc"]
}

# Create virtual machine from marketplace image to unmanaged disk
resource "azurerm_virtual_machine" "vm1" {
    name                  = "vm1"
    location              = "West Europe"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.vm1nic.id}"]
    vm_size               = "Basic_A2"

    storage_image_reference {
        publisher	= "Canonical"
    	offer		= "UbuntuServer"
    	sku		= "16.04-LTS"
    	version		= "latest"
    }

    storage_os_disk { 
	name		= "vm1.vhd"
	vhd_uri		="${azurerm_storage_account.myterraformstorageacc.primary_blob_endpoint}${azurerm_storage_container.myterraformstoragecontainer.name}/vm1.vhd"
        create_option   = "FromImage"
    }

    os_profile {
        computer_name  = "vm1"
        admin_username = "admloc"
        admin_password = "Azerty5*"
    }

    os_profile_linux_config {
	disable_password_authentication = false
    }

    tags {
        environment = "Terraform Demo"
    }
}

#resource "azurerm_image" "mycentos" {
#  name                = "myPackerImage"
#  resource_group_name = "mypackerbuild"
#  location                     = "West Europe"
#}



# Create virtual machine from packer custom image to unmanaged disk
resource "azurerm_virtual_machine" "vm2" {
    name                  = "vm2"
    location              = "West Europe"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.vm2nic.id}"]
    vm_size               = "Basic_A2"

#    storage_image_reference {
#	id = "${azurerm_image.mycentos.id}"
#    }

    storage_image_reference {
        publisher	= "Canonical"
    	offer		= "UbuntuServer"
    	sku		= "16.04-LTS"
    	version		= "latest"
    }

    storage_os_disk { 
	name		= "vm2.vhd"
	vhd_uri		="${azurerm_storage_account.myterraformstorageacc.primary_blob_endpoint}${azurerm_storage_container.myterraformstoragecontainer.name}/vm2.vhd"
        create_option   = "FromImage"
    }

    os_profile {
        computer_name  = "vm2"
        admin_username = "admloc"
        admin_password = "Azerty5*"
    }

    os_profile_linux_config {
	disable_password_authentication = false
    }

    tags {
        environment = "Terraform Demo"
    }
}
