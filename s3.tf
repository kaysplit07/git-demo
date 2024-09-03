output "vm_names" {
  value = [for vm in azurerm_windows_virtual_machine.main : vm.name]
}
