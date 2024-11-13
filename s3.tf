resource "azurerm_network_interface_backend_address_pool_association" "lb_backend_association" {
  for_each                 = azurerm_lb_backend_address_pool.internal_lb_bepool
  network_interface_id     = data.azurerm_network_interface.nic.id  # Assuming a single NIC; adjust if multiple.
  ip_configuration_name    = "ipconfig1"  # Update this if your NIC uses a different IP configuration name
  backend_address_pool_id  = each.value.id
}
