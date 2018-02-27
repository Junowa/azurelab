provider "azurerm" {
    subscription_id = "$${ARM_SUBSCRIPTION_ID}"
    client_id       = "$${ARM_CLIENT_ID}"
    client_secret   = "$${ARM_CLIENT_SECRET}"
    tenant_id       = "$${ARM_TENANT_ID}"
}
