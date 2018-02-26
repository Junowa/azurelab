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
    depends_on = ["azurerm_resource_group.myterraformgroup"]
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "myterrasubnet"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
    depends_on = ["azurerm_virtual_network.myterraformnetwork"]
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
   depends_on=["azurerm_resource_group.myterraformgroup"]
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
    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
    depends_on=["azurerm_resource_group.myterraformgroup"]
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
    depends_on=["azurerm_resource_group.myterraformgroup", "azurerm_network_security_group.myterraformnsg", "azurerm_subnet.myterraformsubnet","azurerm_public_ip.myterraformpublicip"]
}

# Create virtual machine from custom packer image
resource "azurerm_image" "centosTemplate"{
    name			= "myCentosTemplate"
    location			= "westeurope"
    resource_group_name		= "myTemplateResourceGroup"
    os_disk {
         os_type ="linux"
         caching = "ReadWrite"
    }

}

resource "azurerm_virtual_machine" "vm1" {
    name                  = "vm1"
    location              = "West Europe"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.vm1nic.id}"]
    vm_size               = "Basic_A2"

    storage_image_reference {
         id		= "${azurerm_image.centosTemplate.id}"
    }

    storage_os_disk { 
	name		= "myosdisk"
        create_option   = "FromImage"
        caching		= "ReadWrite"
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
