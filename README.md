
## Lab objectives:

* Create a managed image from packer  
* Manage a simple infrastructure from terraform  

    | INTERNET | --- public subnet --- | BASTION | --- private subnet --- | APP1 |    
    

## Packer

Before starting packer, execute azure-setup.sh (requirements setup) 

Start packer with -var-file=variables.json option :

```
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
```

Packer creates an VHD (cf. old commits) or managed image.
Packer create a temporary resource group, and captures generated image in the specified resource group.

To view images :
```
$ az image list
```
 
## Terraform

Create the following terraform env vars:
```
export TF_VAR_ARM_SUBSCRIPTION_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
export TF_VAR_ARM_CLIENT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
export TF_VAR_ARM_CLIENT_SECRET="xxxxxxxxxxxxxxxxxxxxxxxxx"
export TF_VAR_ARM_TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
```

Azure blob storage manage terraform remote state.   
To enable, create beconf.tfvars with the following contents:
```
storage_account_name = "xxxxxxxxxxxxxxxxxxxx"
container_name       = "terralabstate"
access_key           = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
key		     = "terraform.tfstate"
```
    


__Notes:__

To use packer managed template image, use azurerm_image resource, and overwrite os_disk properties.  

Otherwise, Terraform fails at creating managed image form custom image or marketplace image :   

*azurerm_virtual_machine.myterraformvm: compute.VirtualMachinesClient#CreateOrUpdate: Failure sending request: StatusCode=409 -- Original Error: failed request: autorest/azure: Service returned an error. Status=<nil> Code="PropertyChangeNotAllowed" Message="Changing property 'osDisk.name' is not allowed."*  

When using unmanaged image, during destroying, terraform does not delete the os storage disk (vhd) in blob storage container.  Then, Terraform fails when trying to create the resource again as disk already exists.  

Same error as below if osDisk.name is not as follows : "osdisk"+blablabla.   
Name must begin with osdisk.   

### Terraform outputs

To display bastion public ip address:   
```
$ terraform output bastion_public_ip
```


