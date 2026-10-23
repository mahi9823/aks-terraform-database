resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "education"
    managed_by  = "terraform"
    project     = "aks-learning"
  }
}

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.resource_group_name}-logs"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = "education"
    managed_by  = "terraform"
  }
}

resource "azurerm_virtual_network" "aks" {
  for_each = var.aks_clusters

  name                = "${each.value.name}-vnet"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = [each.value.vnet_cidr]

  tags = {
    environment = "education"
    managed_by  = "terraform"
  }
}

resource "azurerm_subnet" "aks" {
  for_each = var.aks_clusters

  name                 = "${each.value.name}-nodes-subnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks[each.key].name
  address_prefixes     = [each.value.aks_subnet_cidr]
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.aks_clusters

  name                = each.value.name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = each.value.dns_prefix
  kubernetes_version  = each.value.kubernetes_version

  # Free Tier control plane (0 USD cluster management fee)
  sku_tier = "Free"

  # Enable local admin accounts for easy educational/learning access via kubectl
  role_based_access_control_enabled = true
  local_account_disabled            = false

  default_node_pool {
    name           = "system"
    node_count     = each.value.node_count
    vm_size        = each.value.vm_size
    vnet_subnet_id = azurerm_subnet.aks[each.key].id

    # Allows student/learner application workloads to run on this single node without needing a second pool
    only_critical_addons_enabled = false
    os_sku                       = "AzureLinux"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
    service_cidr        = each.value.service_cidr
    dns_service_ip      = each.value.dns_service_ip
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  tags = {
    environment = "education"
    managed_by  = "terraform"
    project     = "aks-learning"
  }
}
