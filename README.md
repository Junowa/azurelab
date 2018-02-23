
##Lab objectives:

* Create a managed image from packer  
* Manage a simple infrastructure from terraform  

##Packer

Before starting packer, execute azure-setup.sh (requirements setup) 

Start packer with -var-file=variables.json option :

{
    "client_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx",
    "client_secret": "mysecret",
    "resource_group": "mypackerbuild",
    "storage_account": "mypackeraccount",
    "subscription_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx",
    "tenant_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx",
    "ssh_user": "centos",
    "ssh_pass": "mysecret"
}
  
Packer creates an VHD (not a managed image -investigation in progress).
 
## Terraform

Create provider.tf file as follow:

provider "azurerm" {
    subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
    client_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
    client_secret   = "mysecret"
    tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
}

Terraform fails at creating managed image form custom image or marketplace image.
azurerm_virtual_machine.myterraformvm: compute.VirtualMachinesClient#CreateOrUpdate: Failure sending request: StatusCode=409 -- Original Error: failed request: autorest/azure: Service returned an error. Status=<nil> Code="PropertyChangeNotAllowed" Message="Changing property 'osDisk.name' is not allowed."


