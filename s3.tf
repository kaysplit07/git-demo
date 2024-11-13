provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "test-dev-eus2-testing-rg"
    storage_account_name = "6425dveus2aristb01"
    container_name       = "terraform-state"
    key                  = "LoadBalancer-terraform.tfstate"
    access_key           = ""
  }
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "clientconfig" {}

# Assuming NIC names are passed as a list variable
variable "nic_names" {
  type = list(string)
  description = "List of NIC names to associate with the load balancer."
}

# Fetch multiple NICs using their names
data "azurerm_network_interface" "nic" {
  for_each            = toset(var.nic_names)
  name                = each.value
  resource_group_name = "6425-DEV-EUS2-SGS-RG"
}

# Define Backend Address Pool
resource "azurerm_lb_backend_address_pool" "internal_lb_bepool" {
  for_each        = azurerm_lb.internal_lb
  loadbalancer_id = azurerm_lb.internal_lb[each.key].id
  name            = "internal-${local.purpose_rg}-server-bepool"
}

# Associate each NIC with the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "lb_backend_association" {
  for_each                 = { for nic_key, nic in data.azurerm_network_interface.nic : nic_key => nic }
  network_interface_id     = each.value.id
  ip_configuration_name    = "ipconfig1"  # Ensure this matches the actual configuration name of your NICs
  backend_address_pool_id  = azurerm_lb_backend_address_pool.internal_lb_bepool[0].id  # Adjust for your pool if needed
}

# Additional resources remain the same
