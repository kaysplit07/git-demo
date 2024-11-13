plan: error: failed to plan Terraform configuration in Azure/Azure-LB
╷
│ Error: Reference to "each" in context without for_each
│ 
│   on main.tf line 110, in resource "azurerm_network_interface_backend_address_pool_association" "lb_backend_association":
│  110:   backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
│ 
│ The "each" object can be used only in "module" or "resource" blocks, and
│ only when the "for_each" argument is set.
