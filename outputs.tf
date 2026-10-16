output "aks_cluster_ids" {
  value = {
    for key, cluster in azurerm_kubernetes_cluster.aks : key => cluster.id
  }
}

output "aks_cluster_names" {
  value = {
    for key, cluster in azurerm_kubernetes_cluster.aks : key => cluster.name
  }
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.aks.id
}

output "postgres_server_fqdns" {
  description = "Private FQDNs for PostgreSQL Flexible Servers"
  value = {
    for key, server in azurerm_postgresql_flexible_server.postgres : key => server.fqdn
  }
}

output "postgres_database_names" {
  value = {
    for key, db in azurerm_postgresql_flexible_server_database.app : key => db.name
  }
}

# Password is intentionally not output. Terraform state still contains sensitive data;
# protect the remote state with encryption and strict access controls.
