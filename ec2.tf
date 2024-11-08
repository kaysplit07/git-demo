# Variable to receive the load balancer backend pool ID from the load balancer module
variable "loadbalancer_backend_address_pool_id" {
  description = "ID of the load balancer backend address pool"
  type        = map(string)
}

# Network Interface Resource
resource "azurerm_network_interface" "nic" {
  provider = azurerm.adt
  for_each = { for row_id, inst in local.final_parms_map : row_id => inst }
  location            = local.naming.location
  name                = (each.value).nic_name
  resource_group_name = (each.value).rg_name

  ip_configuration {
    name                          = join("-", [(each.value).vm_name, "nic_config"])
    subnet_id                     = (each.value).nic_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Backend Address Pool Association Resource
resource "azurerm_network_interface_backend_address_pool_association" "VM_to_LB" {
  for_each                         = azurerm_network_interface.nic
  network_interface_id             = each.value.id
  backend_address_pool_id          = var.loadbalancer_backend_address_pool_id[each.key]
}
