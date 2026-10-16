resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "production"
    managed_by  = "terraform"
    project     = "aks-platform"
  }
}

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.resource_group_name}-logs"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = "production"
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
    environment = "production"
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

# Dedicated delegated subnet for Azure Database for PostgreSQL Flexible Server.
resource "azurerm_subnet" "postgres" {
  for_each = var.aks_clusters

  name                 = "${each.value.name}-postgres-subnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks[each.key].name
  address_prefixes     = [each.value.postgres_subnet_cidr]

  delegation {
    name = "postgres-flexible-server-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "postgres" {
  for_each = var.aks_clusters

  name                = "${each.value.name}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.aks.name

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  for_each = var.aks_clusters

  name                  = "${each.value.name}-postgres-dns-link"
  resource_group_name   = azurerm_resource_group.aks.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres[each.key].name
  virtual_network_id    = azurerm_virtual_network.aks[each.key].id

  depends_on = [azurerm_subnet.postgres]
}

resource "random_password" "postgres" {
  for_each = var.aks_clusters

  length           = 28
  special          = true
  override_special = "!#$%&*()-_=+?"
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  for_each = var.aks_clusters

  name                = each.value.postgres_server_name
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location

  version                = "16"
  delegated_subnet_id     = azurerm_subnet.postgres[each.key].id
  private_dns_zone_id     = azurerm_private_dns_zone.postgres[each.key].id
  public_network_access_enabled = false

  administrator_login    = each.value.postgres_admin_login
  administrator_password = random_password.postgres[each.key].result

  storage_mb            = each.value.postgres_storage_mb
  backup_retention_days = 7
  sku_name              = each.value.postgres_sku_name

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgres
  ]

  tags = {
    environment = "production"
    managed_by  = "terraform"
    project     = "aks-platform"
  }
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  for_each = var.aks_clusters

  name      = "appdb"
  server_id = azurerm_postgresql_flexible_server.postgres[each.key].id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.aks_clusters

  name                = each.value.name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = each.value.dns_prefix
  kubernetes_version  = each.value.kubernetes_version

  role_based_access_control_enabled = true
  local_account_disabled            = true
  sku_tier                          = "Standard"

  default_node_pool {
    name                         = "system"
    node_count                   = each.value.system_node_count
    vm_size                      = each.value.system_vm_size
    vnet_subnet_id               = azurerm_subnet.aks[each.key].id
    only_critical_addons_enabled = true
    os_sku                       = "AzureLinux"

    upgrade_settings {
      max_surge = "33%"
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
    environment = "production"
    managed_by  = "terraform"
    project     = "aks-platform"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each = var.aks_clusters

  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[each.key].id
  vm_size               = each.value.user_vm_size
  node_count            = each.value.user_node_count
  mode                  = "User"
  vnet_subnet_id        = azurerm_subnet.aks[each.key].id
  os_sku                = "AzureLinux"
  orchestrator_version  = each.value.kubernetes_version

  upgrade_settings {
    max_surge = "33%"
  }

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}
