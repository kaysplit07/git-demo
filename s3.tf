resource "azurerm_network_interface_backend_address_pool_association" "lb_backend_association" {
  for_each                 = { for nic_key, nic in data.azurerm_network_interface.nic : nic_key => nic }
  network_interface_id     = each.value.id
  ip_configuration_name    = "ipconfig1"  # Ensure this matches the actual configuration name of your NICs
  backend_address_pool_id  = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
}
