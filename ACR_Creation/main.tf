 
variable "allowed_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to be allowed to access the ACR"
}

 locals {
  #allowed_virtual_networks = ["68.65.48.2","68.24.22.2", "68.24.22.4"] 
  allowed_virtual_networks = [for s in var.allowed_subnet_ids : {
    action    = "Allow",
    subnet_id = s
  }]
}
 dynamic "subnet" {
   for_each = [for s in subnets: {
     name = s.name
     prefix = cidrsubnet (local.base.cidr_block, 4, s.number)
   }]
   content {
     subnet = subnet.value.name
     address_prefix = subnet.value.prefix
   }
 }
resource "azurerm_resource_group" "rg" {
  name     = "ACR_ResourceGroup"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                     = "azurecontainerRegistry_rootnyc"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = ["West Europe"]


network_rule_set {
    default_action  = "Deny"
    virtual_network = local.allowed_virtual_networks
  }
}
 
