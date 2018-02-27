variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_TENANT_ID" {}

provider "azurerm" {
    subscription_id = "${var.ARM_SUBSCRIPTION_ID}"
    client_id       = "${var.ARM_CLIENT_ID}"
    client_secret   = "${var.ARM_CLIENT_SECRET}"
    tenant_id       = "${var.ARM_TENANT_ID}"
}
