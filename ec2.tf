terraform {
  backend "azurerm" {
    resource_group_name   = "dev-rg"
    storage_account_name  = "devstorageaccount"
    container_name        = "tfstate"
    key                   = "dev/load_balancer.tfstate"
  }
}
