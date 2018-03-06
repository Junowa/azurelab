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

resource "azurerm_virtual_machine" "bastion" {
    name                  = "bastion"
    location              = "West Europe"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.vm1nic.id}", "${azurerm_network_interface.vm1nic2.id}" ]
    primary_network_interface_id = "${azurerm_network_interface.vm1nic.id}"
    vm_size               = "Basic_A2"

    storage_image_reference {
         id		= "${azurerm_image.centosTemplate.id}"
    }

    storage_os_disk { 
	name		= "osdisk2"
        create_option   = "FromImage"
        caching		= "ReadWrite"
    }


    os_profile {
        computer_name  = "bastion"
        admin_username = "admloc"
        admin_password = "Azerty5*"
    }

    os_profile_linux_config {
	disable_password_authentication = false
    }

    tags {
        environment = "Terraform Demo"
    }
    depends_on = ["azurerm_public_ip.myterraformpublicip"]
}

data "azurerm_public_ip" "myterraformpublicip" {
    name 		= "${azurerm_public_ip.myterraformpublicip.name}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    depends_on 		= ["azurerm_virtual_machine.bastion"] 

}
output "bastion_public_ip" {
	value = "${data.azurerm_public_ip.myterraformpublicip.ip_address}"
}

resource "azurerm_virtual_machine" "app1" {
    name                  = "app1"
    location              = "West Europe"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.vm2nic.id}"]
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
        computer_name  = "app1"
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
