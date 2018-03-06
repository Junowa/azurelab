
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

resource "azurerm_subnet" "privsubnet" {
    name                 = "privsubnet"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.2.0/24"
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

# Create network interface
resource "azurerm_network_interface" "vm1nic2" {
    name                      = "vm1nic2"
    location                  = "West Europe"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"

    ip_configuration {
        name                          = "vm1Nic2Configuration"
        subnet_id                     = "${azurerm_subnet.privsubnet.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.0.2.4"
    }

    tags {
        environment = "Terraform Demo"
    }
    depends_on=["azurerm_resource_group.myterraformgroup","azurerm_subnet.privsubnet"]
}

# Create network interface
resource "azurerm_network_interface" "vm2nic" {
    name                      = "vm2nic"
    location                  = "West Europe"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"

    ip_configuration {
        name                          = "vm2NicConfiguration"
        subnet_id                     = "${azurerm_subnet.privsubnet.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "10.0.2.5"
    }

    tags {
        environment = "Terraform Demo"
    }
    depends_on=["azurerm_resource_group.myterraformgroup","azurerm_subnet.privsubnet"]
}

