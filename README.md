
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
  
Packer creates an VHD.  
When packer creates a managed image, terraform fails to use it (investigation in progress).  

## Terraform

Create provider.tf file as follow:

provider "azurerm" {
    subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
    client_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
    client_secret   = "mysecret"
    tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
}



