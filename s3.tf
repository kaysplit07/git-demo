Resolving the Errors
Here’s a breakdown of the errors and the solutions:

1. Reference to undeclared input variable
The variable vm_names is used in multiple places but is not declared in your Terraform code.

Fix: Declare vm_names in variables.tf
Add a variable declaration for vm_names:

hcl
Copy code
variable "vm_names" {
  description = "List of VM names for NIC configurations"
  type        = list(string)
  default     = []
}
2. Missing resource instance key
This error occurs because azurerm_lb_backend_address_pool.internal_lb_bepool uses a for_each loop. You must reference a specific instance.

Fix: Update the backend_address_pool_id Reference
Use the correct instance key:

hcl
Copy code
backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
3. Missing resource: azurerm_network_interface
The azurerm_network_interface resource is missing but is referenced in the azurerm_network_interface_backend_address_pool_association block.

Fix: Use Data Resource Correctly
If you’re referencing an existing NIC, ensure the azurerm_network_interface data block is correctly defined:

hcl
Copy code
data "azurerm_network_interface" "nic" {
  for_each = toset(var.vm_names)
  name                = join("-", [each.value, "nic-01"])
  resource_group_name = join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, local.purpose, "rg"])
}
Reference the data resource instead of a missing resource:

hcl
Copy code
network_interface_id = data.azurerm_network_interface.nic[each.key].id
4. Missing Instance Key for backend_address_pool_id
The azurerm_lb_backend_address_pool resource is also using for_each, so you need to reference the appropriate instance.

Fix: Add Correct Key Reference
Update:

hcl
Copy code
backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool.id
To:

hcl
Copy code
backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
Corrected Code
Data Block for NIC
hcl
Copy code
data "azurerm_network_interface" "nic" {
  for_each = toset(var.vm_names)
  name                = join("-", [each.value, "nic-01"])
  resource_group_name = join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, local.purpose, "rg"])
}
Backend Association
hcl
Copy code
resource "azurerm_network_interface_backend_address_pool_association" "lb_associations" {
  for_each = toset(var.vm_names)

  network_interface_id    = data.azurerm_network_interface.nic[each.key].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
}
Variable Declaration
hcl
Copy code
variable "vm_names" {
  description = "List of VM names for NIC configurations"
  type        = list(string)
  default     = []
}
Testing Recommendations
Validate Configuration: Run:

bash
Copy code
terraform validate
Plan the Deployment: Run:

bash
Copy code
terraform plan -var="vm_names=['VM1', 'VM2', 'VM3']"
Apply: Ensure everything works by running:

bash
Copy code
terraform apply -auto-approve -var="vm_names=['VM1', 'VM2', 'VM3']"
These fixes address the missing variable declarations, correct instance references for resources using for_each, and properly define the azurerm_network_interface data block. Let me know if you encounter further issues!







You said:
provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.100.0" 
    }
    
  }
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}  # Read the current subscription info

data "azurerm_client_config" "clientconfig" {}  # Read the current client config

data "azurerm_network_interface" "nic" {
  for_each = toset(var.vm_names)
  name                = join("-", [each.value, "nic-01"])
  resource_group_name = join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, local.purpose, "rg"])
}


locals {
  get_data = csvdecode(file("../parameters.csv"))
  # Define data for naming standards
  #vm_names_list = var.vm_names != [] ? var.vm_names : split(",", var.vm_names[0])
  vm_names_list = can(length(var.vm_names)) ? var.vm_names:[var.vm_names]
  naming = {
    bu                = lower(split("-", data.azurerm_subscription.current.display_name)[1])  # Read app/bu from the subscription data block
    environment       = lower(split("-", data.azurerm_subscription.current.display_name)[2])  # Read environment from subscription data block
    locations         = var.location
    nn                = lower(split("-", data.azurerm_subscription.current.display_name)[3])
    subscription_name = data.azurerm_subscription.current.display_name
    subscription_id   = data.azurerm_subscription.current.id
  }
  env_location = {
    env_abbreviation       = var.environment_map[local.naming.environment]
    locations_abbreviation = var.location_map[local.naming.locations]
  }

  # Extract the full purpose (including sequence) from RGname or var.purpose
  purpose_full = var.RGname != "" ? lower(split("-", var.RGname)[3]) : var.purpose

  # Split the purpose_full into purpose and sequence
  purpose_parts = split("/", local.purpose_full)

  # Assign purpose and sequence, defaulting sequence to "01" if not provided
  purpose    = local.purpose_parts[0]
  sequence   = length(local.purpose_parts) > 1 ? local.purpose_parts[1] : "01"
  purpose_rg = local.purpose
}

data "azurerm_resource_group" "rg" {
  for_each = { for inst in local.get_data : inst.unique_id => inst }
  name     = join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, local.purpose, "rg"])
}

output "resource_group_name" {
  value = data.azurerm_resource_group.rg
}

data "azurerm_virtual_network" "vnet" {
  for_each = { for index, inst in local.get_data : index => inst }
   name = (lookup(each.value, "vnet_name", null) != null && lookup(each.value, "vnet_name", "") != "") ? each.value.vnet_name : join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, "vnet", local.naming.nn])
   resource_group_name  = (lookup(each.value, "vnet_resource_group", null) != null && lookup(each.value, "vnet_resource_group", "") != "") ? each.value.vnet_resource_group : join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, "spokenetwork-rg"])
  
}

output "virtual_network_id" {
  value      = data.azurerm_virtual_network.vnet
  sensitive  = true
}

data "azurerm_subnet" "subnet" {
  for_each = { for index, inst in local.get_data : index => inst }
  name                 = (lookup(each.value, "subnet_name", null) != null && lookup(each.value, "subnet_name", "") != "") ? each.value.subnet_name : var.subnetname //lz<app>-<env>-<region>-<purpose>-snet-<nn>
  virtual_network_name = data.azurerm_virtual_network.vnet[each.key].name
  resource_group_name  = (lookup(each.value, "vnet_resource_group", null) != null && lookup(each.value, "vnet_resource_group", "") != "") ? each.value.vnet_resource_group : join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, "spokenetwork-rg"])
}

output "subnet_id" {
  value      = data.azurerm_subnet.subnet
  sensitive  = true
}

# Azure Load Balancer Resource
resource "azurerm_lb" "internal_lb" {
  for_each            = { for inst in local.get_data : inst.unique_id => inst }
  name                = join("-", ["ari", local.naming.environment, local.env_location.locations_abbreviation, local.purpose_rg, "lbi", local.sequence])
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  sku                 = lookup(each.value, "sku_name", var.sku_name)

  frontend_ip_configuration {
    name                          = "internal-${local.purpose_rg}-server-feip"
    subnet_id                     = data.azurerm_subnet.subnet["0"].id
    private_ip_address            = var.private_ip_address  # Use the variable
    private_ip_address_allocation = "Static"
  }
}

# Define Backend Address Pool
resource "azurerm_lb_backend_address_pool" "internal_lb_bepool" {
  for_each        = azurerm_lb.internal_lb
  loadbalancer_id = azurerm_lb.internal_lb[each.key].id
  name            = "internal-${local.purpose_rg}-server-bepool"
}

# resource "azurerm_network_interface_backend_address_pool_association" "lb_backend_association" {
#   for_each = {
#     for idx, pool in azurerm_lb_backend_address_pool.internal_lb_bepool : idx => {
#       pool_id = pool.id
#       nic_id  = data.azurerm_network_interface.nic[idx].id
#       vm_name = local.vm_names_list[idx]
#     }
#   }

#   network_interface_id    = each.value.nic_id
#   ip_configuration_name   = join("-", [each.value.vm_name, "nic1_config"])
#   backend_address_pool_id = each.value.pool_id
# }

resource "azurerm_network_interface_backend_address_pool_association" "lb_associations" {
  for_each = toset(var.vm_names)
  network_interface_id    = data.azurerm_network_interface.nic[each.key].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
}


# Load Balancer Probe
resource "azurerm_lb_probe" "tcp_probe" {
  for_each            = azurerm_lb.internal_lb
  name                = "internal-${local.purpose_rg}-server-tcp-probe"
  loadbalancer_id     = azurerm_lb.internal_lb[each.key].id
  protocol            = "Tcp"
  port                = 20005
  interval_in_seconds = 5
  number_of_probes    = 5
}

# Load Balancer TCP Rule
resource "azurerm_lb_rule" "tcp_rule" {
  for_each                       = azurerm_lb.internal_lb
  name                           = "internal-${local.purpose_rg}-server-tcp-lbrule"
  loadbalancer_id                = azurerm_lb.internal_lb[each.key].id
  protocol                       = "Tcp"
  frontend_port                  = 20000
  backend_port                   = 20000
  frontend_ip_configuration_name = azurerm_lb.internal_lb[each.key].frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id]
  idle_timeout_in_minutes        = 5
  enable_floating_ip             = false
  enable_tcp_reset               = false
  disable_outbound_snat          = false
  probe_id                       = azurerm_lb_probe.tcp_probe[each.key].id
}

# Load Balancer HTTPS Rule
resource "azurerm_lb_rule" "https_rule" {
  for_each                       = azurerm_lb.internal_lb
  name                           = "internal-${local.purpose_rg}-server-https-lbrule"
  loadbalancer_id                = azurerm_lb.internal_lb[each.key].id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.internal_lb[each.key].frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id]
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
  enable_tcp_reset               = false
  disable_outbound_snat          = false
  probe_id                       = azurerm_lb_probe.tcp_probe[each.key].id
}


╷
│ Error: Inconsistent conditional result types
│ 
│   on main.tf line 31, in locals:
│   31:   vm_names_list = can(length(var.vm_names)) ? var.vm_names:[var.vm_names]
│     ├────────────────
│     │ var.vm_names is a list of string
│ 
│ The true and false result expressions must have consistent types. The
│ 'true' value is list of string, but the 'false' value is tuple.
╵
╷
│ Error: Missing required argument
│ 
│   on main.tf line 127, in resource "azurerm_network_interface_backend_address_pool_association" "lb_associations":
│  127: resource "azurerm_network_interface_backend_address_pool_association" "lb_associations" {
│ 
│ The argument "ip_configuration_name" is required, but no definition was
│ found.
ChatGPT said:
ChatGPT
Here are the solutions to the errors:

1. Inconsistent conditional result types
The error is caused by the vm_names_list local variable:

hcl
Copy code
vm_names_list = can(length(var.vm_names)) ? var.vm_names:[var.vm_names]
Cause
The true and false branches return different types:

var.vm_names is a list of strings.
[var.vm_names] creates a tuple of lists, which is inconsistent.
Fix
Ensure both branches return the same type:

hcl
Copy code
vm_names_list = can(length(var.vm_names)) ? var.vm_names : [var.vm_names][0]
This ensures the result is always a list of strings.

2. Missing required argument: ip_configuration_name
The azurerm_network_interface_backend_address_pool_association resource is missing the ip_configuration_name argument.

Fix
Add the ip_configuration_name to the resource:

hcl
Copy code
resource "azurerm_network_interface_backend_address_pool_association" "lb_associations" {
  for_each = toset(var.vm_names)
  
  network_interface_id    = data.azurerm_network_interface.nic[each.key].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
  ip_configuration_name   = join("-", [each.key, "nic1_config"]) # Adjust as per your configuration
}
Ensure the value of ip_configuration_name matches the actual IP configuration name used in the NICs.

Updated Code Snippets
Fixed locals Block
hcl
Copy code
locals {
  get_data = csvdecode(file("../parameters.csv"))
  
  vm_names_list = can(length(var.vm_names)) ? var.vm_names : [var.vm_names][0]
  
  naming = {
    bu                = lower(split("-", data.azurerm_subscription.current.display_name)[1])
    environment       = lower(split("-", data.azurerm_subscription.current.display_name)[2])
    locations         = var.location
    nn                = lower(split("-", data.azurerm_subscription.current.display_name)[3])
    subscription_name = data.azurerm_subscription.current.display_name
    subscription_id   = data.azurerm_subscription.current.id
  }
  env_location = {
    env_abbreviation       = var.environment_map[local.naming.environment]
    locations_abbreviation = var.location_map[local.naming.locations]
  }

  purpose_full = var.RGname != "" ? lower(split("-", var.RGname)[3]) : var.purpose

  purpose_parts = split("/", local.purpose_full)

  purpose    = local.purpose_parts[0]
  sequence   = length(local.purpose_parts) > 1 ? local.purpose_parts[1] : "01"
  purpose_rg = local.purpose
}
Fixed Backend Association Resource
hcl
Copy code
resource "azurerm_network_interface_backend_address_pool_association" "lb_associations" {
  for_each = toset(var.vm_names)

  network_interface_id    = data.azurerm_network_interface.nic[each.key].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
  ip_configuration_name   = join("-", [each.key, "nic1_config"]) # Update this value as per actual NIC IP configuration name
}
Additional Notes
Verify ip_configuration_name Ensure ip_configuration_name aligns with the actual configuration of your Azure NICs.

Run Terraform Commands

Validate:
bash
Copy code
terraform validate
Plan:
bash
Copy code
terraform plan -var="vm_names=['VM1', 'VM2', 'VM3']"
Apply:
bash
Copy code
terraform apply -auto-approve -var="vm_names=['VM1', 'VM2', 'VM3']"
Test Different vm_names Inputs Validate behavior with different configurations to ensure robustness.

Let me know if you encounter any further issues!






You said:
###main.tf

provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.100.0" 
    }
    
  }
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}  # Read the current subscription info

data "azurerm_client_config" "clientconfig" {}  # Read the current client config

data "azurerm_network_interface" "nic" {
  for_each = toset(var.vm_names)
  name                = join("-", [each.value, "nic-01"])
  resource_group_name = join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, local.purpose, "rg"])
}


locals {
  get_data = csvdecode(file("../parameters.csv"))
  
  vm_names_list = can(length(var.vm_names)) ? var.vm_names : [var.vm_names][0]
  
  naming = {
    bu                = lower(split("-", data.azurerm_subscription.current.display_name)[1])
    environment       = lower(split("-", data.azurerm_subscription.current.display_name)[2])
    locations         = var.location
    nn                = lower(split("-", data.azurerm_subscription.current.display_name)[3])
    subscription_name = data.azurerm_subscription.current.display_name
    subscription_id   = data.azurerm_subscription.current.id
  }
  env_location = {
    env_abbreviation       = var.environment_map[local.naming.environment]
    locations_abbreviation = var.location_map[local.naming.locations]
  }

  purpose_full = var.RGname != "" ? lower(split("-", var.RGname)[3]) : var.purpose

  purpose_parts = split("/", local.purpose_full)

  purpose    = local.purpose_parts[0]
  sequence   = length(local.purpose_parts) > 1 ? local.purpose_parts[1] : "01"
  purpose_rg = local.purpose
}
data "azurerm_resource_group" "rg" {
  for_each = { for inst in local.get_data : inst.unique_id => inst }
  name     = join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, local.purpose, "rg"])
}

output "resource_group_name" {
  value = data.azurerm_resource_group.rg
}

data "azurerm_virtual_network" "vnet" {
  for_each = { for index, inst in local.get_data : index => inst }
   name = (lookup(each.value, "vnet_name", null) != null && lookup(each.value, "vnet_name", "") != "") ? each.value.vnet_name : join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, "vnet", local.naming.nn])
   resource_group_name  = (lookup(each.value, "vnet_resource_group", null) != null && lookup(each.value, "vnet_resource_group", "") != "") ? each.value.vnet_resource_group : join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, "spokenetwork-rg"])
  
}

output "virtual_network_id" {
  value      = data.azurerm_virtual_network.vnet
  sensitive  = true
}

data "azurerm_subnet" "subnet" {
  for_each = { for index, inst in local.get_data : index => inst }
  name                 = (lookup(each.value, "subnet_name", null) != null && lookup(each.value, "subnet_name", "") != "") ? each.value.subnet_name : var.subnetname //lz<app>-<env>-<region>-<purpose>-snet-<nn>
  virtual_network_name = data.azurerm_virtual_network.vnet[each.key].name
  resource_group_name  = (lookup(each.value, "vnet_resource_group", null) != null && lookup(each.value, "vnet_resource_group", "") != "") ? each.value.vnet_resource_group : join("-", [local.naming.bu, local.naming.environment, local.env_location.locations_abbreviation, "spokenetwork-rg"])
}

output "subnet_id" {
  value      = data.azurerm_subnet.subnet
  sensitive  = true
}

# Azure Load Balancer Resource
resource "azurerm_lb" "internal_lb" {
  for_each            = { for inst in local.get_data : inst.unique_id => inst }
  name                = join("-", ["ari", local.naming.environment, local.env_location.locations_abbreviation, local.purpose_rg, "lbi", local.sequence])
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  sku                 = lookup(each.value, "sku_name", var.sku_name)

  frontend_ip_configuration {
    name                          = "internal-${local.purpose_rg}-server-feip"
    subnet_id                     = data.azurerm_subnet.subnet["0"].id
    private_ip_address            = var.private_ip_address  # Use the variable
    private_ip_address_allocation = "Static"
  }
}

# Define Backend Address Pool
resource "azurerm_lb_backend_address_pool" "internal_lb_bepool" {
  for_each        = azurerm_lb.internal_lb
  loadbalancer_id = azurerm_lb.internal_lb[each.key].id
  name            = "internal-${local.purpose_rg}-server-bepool"
}

# resource "azurerm_network_interface_backend_address_pool_association" "lb_backend_association" {
#   for_each = {
#     for idx, pool in azurerm_lb_backend_address_pool.internal_lb_bepool : idx => {
#       pool_id = pool.id
#       nic_id  = data.azurerm_network_interface.nic[idx].id
#       vm_name = local.vm_names_list[idx]
#     }
#   }

#   network_interface_id    = each.value.nic_id
#   ip_configuration_name   = join("-", [each.value.vm_name, "nic1_config"])
#   backend_address_pool_id = each.value.pool_id
# }

resource "azurerm_network_interface_backend_address_pool_association" "lb_associations" {
  for_each = toset(var.vm_names)
  network_interface_id    = data.azurerm_network_interface.nic[each.key].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
  ip_configuration_name   = join("-", [each.key, "nic1_config"]) # Update this value as per actual NIC IP configuration name
}

# Load Balancer Probe
resource "azurerm_lb_probe" "tcp_probe" {
  for_each            = azurerm_lb.internal_lb
  name                = "internal-${local.purpose_rg}-server-tcp-probe"
  loadbalancer_id     = azurerm_lb.internal_lb[each.key].id
  protocol            = "Tcp"
  port                = 20005
  interval_in_seconds = 5
  number_of_probes    = 5
}

# Load Balancer TCP Rule
resource "azurerm_lb_rule" "tcp_rule" {
  for_each                       = azurerm_lb.internal_lb
  name                           = "internal-${local.purpose_rg}-server-tcp-lbrule"
  loadbalancer_id                = azurerm_lb.internal_lb[each.key].id
  protocol                       = "Tcp"
  frontend_port                  = 20000
  backend_port                   = 20000
  frontend_ip_configuration_name = azurerm_lb.internal_lb[each.key].frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id]
  idle_timeout_in_minutes        = 5
  enable_floating_ip             = false
  enable_tcp_reset               = false
  disable_outbound_snat          = false
  probe_id                       = azurerm_lb_probe.tcp_probe[each.key].id
}

# Load Balancer HTTPS Rule
resource "azurerm_lb_rule" "https_rule" {
  for_each                       = azurerm_lb.internal_lb
  name                           = "internal-${local.purpose_rg}-server-https-lbrule"
  loadbalancer_id                = azurerm_lb.internal_lb[each.key].id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.internal_lb[each.key].frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id]
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
  enable_tcp_reset               = false
  disable_outbound_snat          = false
  probe_id                       = azurerm_lb_probe.tcp_probe[each.key].id
}

###variable.tf

variable "environment_map" {
  type = map
  description = "environment"
  default = {
    "dev"  = "dev"
    "uat" = "uat"
    "fof" = "fof"
    "prod" = "prod"
    "qa" = "qa"
  }
}

variable "location_map" {
  type = map
  description = "location_map"
    default = {
    "eastus2"  = "eus2"
    "centralus" = "cus"
    "uksouth" = "uks"
    "ukwest" = "ukw"
    "us"= "eus2"
  
  }

}

variable "RGname" {
  description = "Optional existing Resource Group name. If not provided, it will be computed."
  type        = string
  default     = ""
}

variable "sku_name" {
  description = "SKU name for the Load Balancer."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku_name)
    error_message = "sku_name must be either 'Basic' or 'Standard'."
  }
}

variable "location" {
  type = string
  description = "location"
  default = "eastus2"
}


variable "purpose_rg" {
  type        = string
  default     = "default"
  description = "(Required) The purpose segment of the Resource Group name. Should not exceed 5 characters."
  validation {
    condition     = strcontains(var.purpose_rg, "-") ? length(var.purpose_rg) <= 80 : length(var.purpose_rg) <= 5
    error_message = "(Required) Purpose segment cannot exceed 5 characters. Name cannot exceed 80."
  }  
 }

# Define the name for the subnet
variable "subnetname" {
  type = string
  default = "5874-dev-eus2-aks-snet-02"
#  sensitive = true
  
}

variable "private_ip_address" {
  description = "The private IP address to assign to the load balancer frontend configuration."
  type        = string
  default     = "10.82.58.234"  # You can change the default value as needed
}

variable "purpose" {
  description = "Purpose of the resources, used in naming conventions."
  type        = string
}

# variable "vm_names" {
#   type        = list(string)
#   description = "List of VM names for NIC IP configuration."
#   default     = [""]
# }

variable "vm_list" {
  type = list(object({
    vm_name  = string
    nic_name = string
  }))
}


variable "vm_names" {
  description = "List of VM names for NIC configurations"
  type        = list(string)
  default     = []
}

##lbcreate.yml

name: 'zLoad Balancer (Call)'
run-name: '${{github.actor}} - Creating Load Balancer'
on:
  workflow_call:
    inputs:
      requestType:
        type: string
        required: false
      location:
        type: string
        required: true
      environment:
        type: string
        required: true
      purpose:
        type: string
        required: false
      purposeRG:
        type: string
        required: false
      RGname:
        type: string
        required: false
      subnetname:
        type: string
        required: false
      sku_name:
        type: string
        required: false
      private_ip_address:
        type: string
        required: false
      vm_list:
        type: string
        required: false
env:
  permissions:
  contents: read
jobs:
  lb-create:
    name: 'Create Azure Load Balancer'
    env:
      ARM_CLIENT_ID:        ${{secrets.AZURE_CLIENT_ID}}
      ARM_CLIENT_SECRET:    ${{secrets.AZURE_CLIENT_SECRET}}
      ARM_TENANT_ID:        ${{secrets.AZURE_TENANT_ID}}
      ARM_SUBSCRIPTION_ID:  ${{secrets.AZURE_SUBSCRIPTION_ID}}
      ROOT_PATH:            'Azure/Azure-LB'
    runs-on: 
      group: aks-runners
    environment: ${{ inputs.environment }}
    defaults:
      run:
        shell: bash
        working-directory: 'Azure/Azure-LB'
    steps:
      - name: 'Checkout - Load Balancer'
        uses: actions/checkout@v3
      - name: 'Setup Node.js'
        uses: actions/setup-node@v2
        with:
          node-version: '20'  # Specify the required Node.js version  
      - name: Validate VM List
        if: ${{ inputs.vm_list == null && (inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)') }}
        run: |
            echo "Error: vm_list is required for the selected requestType." && exit 1   
      - name: Parse VM List
        id: parse_vm_list
        run: |
          if [ -n "${{ inputs.vm_list }}" ]; then
             echo "VM_LIST=$(echo '${{ inputs.vm_list }}' | jq -c '.')" >> "$GITHUB_ENV"
          else
            echo "VM_LIST=[]" >> "$GITHUB_ENV"
          fi
        env:
          VM_LIST: '${{ inputs.vm_list }}'        
      - name: 'Setup Terraform'
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: latest      
      - id: envvars
        name: Set environment variables based on deployment environment
        run: |
            if [ "${{ inputs.environment }}" = "prod" ]; then
                echo "BACKEND_STORAGE_ACCOUNT=ngpdeus26425st01" >> "$GITHUB_ENV"
                echo "BACKEND_RESOURCE_GROUP=6425-Prod-eus2-main-rg" >> "$GITHUB_ENV"
                echo "TF_VAR_env=prod" >> "$GITHUB_ENV"
            elif [ "${{ inputs.environment }}" = "uat" ]; then
                echo "BACKEND_STORAGE_ACCOUNT=nguteus26425st01" >> "$GITHUB_ENV"
                echo "BACKEND_RESOURCE_GROUP=6425-uat-eus2-main-rg" >> "$GITHUB_ENV"
                echo "TF_VAR_env=uat" >> "$GITHUB_ENV"
            else
                echo "BACKEND_STORAGE_ACCOUNT=6425dveus2aristb01" >> "$GITHUB_ENV"
                echo "BACKEND_RESOURCE_GROUP=test-dev-eus2-testing-rg" >> "$GITHUB_ENV"
                echo "TF_VAR_env=dev" >> "$GITHUB_ENV"
            fi 

      - name: 'Terraform Initialize - Load Balancer'
        run: terraform init -backend-config="resource_group_name=$BACKEND_RESOURCE_GROUP" -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT" -backend-config="container_name=terraform-state" -backend-config="key=${{ inputs.environment }}-lb-terraform.tfstate" -input=false
        env:
          TF_VAR_requesttype:              '${{inputs.requestType}}'
          TF_VAR_location:                 '${{inputs.location}}'
          TF_VAR_environment:              '${{inputs.environment}}'
          TF_VAR_purpose:                  '${{inputs.purpose}}'
          TF_VAR_purpose_rg:               '${{inputs.purposeRG}}'
          TF_VAR_RGname:                   '${{inputs.RGname}}'
          TF_VAR_subnetname:               '${{inputs.subnetname}}'
          TF_VAR_sku_name:                 '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:       '${{inputs.private_ip_address}}'
          TF_VAR_vm_list:                  '${{ env.TF_VAR_vm_list }}'
      - name: 'Terraform Plan - Load Balancer'
        if: ${{ inputs.vm_list && (inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)') }}
        #if: ${{ inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)' }}
        run: terraform plan
        env:
          TF_VAR_requesttype:         '${{inputs.requestType}}'
          TF_VAR_location:            '${{inputs.location}}'
          TF_VAR_environment:         '${{inputs.environment}}'
          TF_VAR_purpose:             '${{inputs.purpose}}'
          TF_VAR_purpose_rg:          '${{inputs.purposeRG}}'
          TF_VAR_RGname:              '${{inputs.RGname}}'
          TF_VAR_subnetname:          '${{inputs.subnetname}}'
          TF_VAR_sku_name:            '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:  '${{inputs.private_ip_address}}'
          TF_VAR_vm_list:             '${{ env.TF_VAR_vm_list }}'
      - name: 'Terraform Apply - Load Balancer'
        if: ${{ inputs.vm_list && inputs.requestType == 'Create (with New RG)' }} ||  ${{ inputs.vm_list && inputs.requestType == 'Create (with Existing RG)' }}
        run: terraform apply -auto-approve
        env:
          TF_VAR_requesttype:         '${{inputs.requestType}}'
          TF_VAR_location:            '${{inputs.location}}'
          TF_VAR_environment:         '${{inputs.environment}}'
          TF_VAR_purpose:             '${{inputs.purpose}}'
          TF_VAR_purpose_rg:          '${{inputs.purposeRG}}'
          TF_VAR_RGname:              '${{inputs.RGname}}'
          TF_VAR_subnetname:          '${{inputs.subnetname}}'
          TF_VAR_sku_name:            '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:  '${{inputs.private_ip_address}}'
          TF_VAR_vm_list:             '${{ env.TF_VAR_vm_list }}'
      - name: 'Terraform Remove - Load Balancer'
        if: ${{ inputs.requestType == 'Remove' }}
        run: terraform destroy -auto-approve
        env:
          TF_VAR_requesttype:         '${{inputs.requestType}}'
          TF_VAR_location:            '${{inputs.location}}'
          TF_VAR_environment:         '${{inputs.environment}}'
          TF_VAR_purpose:             '${{inputs.purpose}}'
          TF_VAR_purpose_rg:          '${{inputs.purposeRG}}'
          TF_VAR_RGname:              '${{inputs.RGname}}'
          TF_VAR_subnetname:          '${{inputs.subnetname}}'
          TF_VAR_sku_name:            '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:  '${{inputs.private_ip_address}}'
          TF_VAR_vm_list:             '${{ env.TF_VAR_vm_list }}'


##lbdeploy.yml
name: 'Deploy Load Balancer'
run-name: 'Load Balancer - ${{inputs.environment}} purpose: ${{inputs.purpose}} : ${{inputs.requesttype}}'
on:
  workflow_dispatch:
    inputs:
      requesttype:
        type: choice
        required: true
        description: Request Type
        options:
            - Create (with New RG)
            - Create (with Existing RG)
            - Remove
        default: "Create (with New RG)"
      environment:
        type: choice
        required: true
        description: Environment
        options:
          - DEV
          - UAT
          - QA
          - PROD
      location:
        type: choice
        required: true
        description: Deployment Location
        options:
          - Select the location
          - eastus2
          - uksouth
          - centralus
          - ukwest
      sku_name:
        type: choice
        required: false
        description: SKU for Load Balancer
        options:
          - Standard
          - Basic
        default: "Standard"
      purpose:
        type: string
        required: true
        description: Purpose of the Load Balancer
      RGname:
          type: string
          required: false
      purposeRG:
        type: string
        required: true
        description: Resource Group Purpose.......... Hyphen designate an existing RG
      subnetname:
        type: string
        required: true
        description: Subnet name for Load Balancer.
      private_ip_address:
        type: string
        required: false
        description: Private IP address for Load Balancer frontend configuration.
      vm_names:
        description: "List of VM names for NIC IP configuration"
        required: false
        default: '["VM1", "VM2", "VM3"]'
jobs:
  resource_group:
   #if: (github.event.inputs.requesttype == 'Create (with New RG)')
    if: ${{ inputs.vm_list == null && (inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)') }}
    name: 'Resource Group ${{inputs.purposeRG}}'
    uses: ./.github/workflows/CreateResourceGroup.yml
    secrets: inherit
    with:
      name:                 'resource-group'
      subscription:         'SNow Input'
      environment:          '${{inputs.environment}}' 
      location:             '${{inputs.location}}' 
      purpose:              '${{inputs.purposeRG}}'
  
  load_balancer_new_rg:
    #if: (github.event.inputs.requesttype == 'Create (with New RG)')
    if: ${{ inputs.vm_list == null && (inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)') }}
    name: 'Load Balancer ${{inputs.purpose}}'
    uses: ./.github/workflows/LBCreate.yml
    needs: resource_group
    secrets: inherit
    with:
      requesttype:               '${{inputs.requesttype}}'
      environment:               '${{inputs.environment}}'
      location:                  '${{inputs.location}}'
      sku_name:                  '${{inputs.sku_name}}'
      purpose:                   '${{inputs.purpose}}'
      RGname:                    '${{inputs.RGname}}'
      purposeRG:                 '${{inputs.purposeRG}}'
      subnetname:                '${{inputs.subnetname}}'
      private_ip_address:        '${{inputs.private_ip_address}}'
     # vm_names:                  '${{inputs.vm_names}}'
      vm_list: '[{"vm_name": "VM1", "nic_name": "NIC1"}, {"vm_name": "VM2", "nic_name": "NIC2"}]'
  load_balancer_existing_rg:
    if: (github.event.inputs.requesttype == 'Create (with Existing RG)')
    name: 'Load Balancer ${{inputs.purpose}}'
    uses: ./.github/workflows/LBCreate.yml
    secrets: inherit
    with:
      requesttype:               '${{inputs.requesttype}}'
      environment:               '${{inputs.environment}}'
      location:                  '${{inputs.location}}'
      sku_name:                  '${{inputs.sku_name}}'
      purpose:                   '${{inputs.purpose}}'
      purposeRG:                 '${{inputs.purposeRG}}'
      subnetname:                '${{inputs.subnetname}}'
      RGname:                    '${{inputs.RGname}}'
      private_ip_address:        '${{inputs.private_ip_address}}'
      #vm_names:                  '${{inputs.vm_names}}'
      vm_list: '[{"vm_name": "VM1", "nic_name": "NIC1"}, {"vm_name": "VM2", "nic_name": "NIC2"}]'
  
  load_balancer_remove:
    if: (github.event.inputs.requesttype == 'Remove')
    name: 'Maintain Load Balancer ${{inputs.purpose}}'
    uses: ./.github/workflows/LBCreate.yml
    secrets: inherit
    with:
      requesttype:               '${{inputs.requesttype}}'
      environment:               '${{inputs.environment}}'
      location:                  '${{inputs.location}}'
      sku_name:                  '${{inputs.sku_name}}'
      purpose:                   '${{inputs.purpose}}'
      purposeRG:                 '${{inputs.purposeRG}}'
      RGname:                    '${{inputs.RGname}}'
      subnetname:                '${{inputs.subnetname}}'
      private_ip_address:        '${{inputs.private_ip_address}}'
      #vm_names:                  '${{inputs.vm_names}}'
      vm_list: '[{"vm_name": "VM1", "nic_name": "NIC1"}, {"vm_name": "VM2", "nic_name": "NIC2"}]'
ChatGPT said:
ChatGPT
Here are the suggested corrections and improvements for your configuration:

1. Error: Conditional Checks for vm_list
In lbdeploy.yml, you have several conditions like this:

yaml
Copy code
if: ${{ inputs.vm_list == null && (inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)') }}
Fix
GitHub Actions does not interpret == null as expected in YAML. Replace it with:

yaml
Copy code
if: ${{ !inputs.vm_list && (inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)') }}
2. TF_VAR_vm_list Handling
In lbcreate.yml, you attempt to pass vm_list as an environment variable:

yaml
Copy code
TF_VAR_vm_list: '${{ env.TF_VAR_vm_list }}'
Issue
vm_list is treated as a string but should be a JSON-encoded object for Terraform.

Fix
Use jq to parse the list and export it correctly:

yaml
Copy code
- name: Parse VM List
  id: parse_vm_list
  run: |
    if [ -n "${{ inputs.vm_list }}" ]; then
       echo "TF_VAR_vm_list=$(echo '${{ inputs.vm_list }}' | jq -c '.')" >> $GITHUB_ENV
    else
      echo "TF_VAR_vm_list=[]" >> $GITHUB_ENV
    fi
3. azurerm_network_interface_backend_address_pool_association in main.tf
The for_each in this resource is using toset(var.vm_names), but the pool ID mapping might not align properly.

Fix
Use the full vm_list object for the mapping:

hcl
Copy code
resource "azurerm_network_interface_backend_address_pool_association" "lb_associations" {
  for_each = { for vm in var.vm_list : vm.vm_name => vm }

  network_interface_id    = data.azurerm_network_interface.nic[each.key].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
  ip_configuration_name   = each.value.nic_name
}
4. Input Validation for vm_list
You might want to validate vm_list in Terraform to ensure it contains both vm_name and nic_name.

Add Validation
In variable.tf:

hcl
Copy code
variable "vm_list" {
  type = list(object({
    vm_name  = string
    nic_name = string
  }))
  default = []
  validation {
    condition     = alltrue([for vm in var.vm_list : can(vm.vm_name) && can(vm.nic_name)])
    error_message = "Each object in vm_list must have both 'vm_name' and 'nic_name'."
  }
}
5. Simplify Defaults in variable.tf
If you're using vm_list as the main source of truth, vm_names may be redundant.

Fix
Remove vm_names or derive it from vm_list:

hcl
Copy code
variable "vm_names" {
  type = list(string)
  default = [for vm in var.vm_list : vm.vm_name]
}
6. Correct Resource Group Condition
For resource_group in lbdeploy.yml:

yaml
Copy code
if: ${{ inputs.vm_list == null && (inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)') }}
Fix
Update to:

yaml
Copy code
if: ${{ !inputs.vm_list && (inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)') }}
7. Default vm_list in lbdeploy.yml
If you expect a default vm_list, encode it as JSON:

yaml
Copy code
vm_list:
  description: "List of VM names for NIC IP configuration"
  required: false
  default: '[{"vm_name": "VM1", "nic_name": "NIC1"}, {"vm_name": "VM2", "nic_name": "NIC2"}]'
Updated Key Snippets
lbcreate.yml
yaml
Copy code
- name: Parse VM List
  id: parse_vm_list
  run: |
    if [ -n "${{ inputs.vm_list }}" ]; then
       echo "TF_VAR_vm_list=$(echo '${{ inputs.vm_list }}' | jq -c '.')" >> $GITHUB_ENV
    else
      echo "TF_VAR_vm_list=[]" >> $GITHUB_ENV
    fi
main.tf
hcl
Copy code
resource "azurerm_network_interface_backend_address_pool_association" "lb_associations" {
  for_each = { for vm in var.vm_list : vm.vm_name => vm }

  network_interface_id    = data.azurerm_network_interface.nic[each.key].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_bepool[each.key].id
  ip_configuration_name   = each.value.nic_name
}
With these corrections, your workflow should properly handle vm_list as a dynamic input while ensuring robust Terraform resource mapping.











ChatGPT
