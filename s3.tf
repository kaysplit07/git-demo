 Error: Invalid index
│ 
│   on main.tf line 134, in resource "azurerm_network_interface_backend_address_pool_association" "lb_backend_association":
│  134:   backend_address_pool_id  = azurerm_lb_backend_address_pool.internal_lb_bepool[0].id  # Adjust for your pool if needed
│     ├────────────────
│     │ azurerm_lb_backend_address_pool.internal_lb_bepool is object with 1 attribute "1"
│ 
│ The given key does not identify an element in this collection value. An
│ object only supports looking up attributes by name, not by numeric index.
