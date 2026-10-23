output "resource_group_name" {
  description = "Resource group name where the cluster is deployed"
  value       = azurerm_resource_group.aks.name
}

output "aks_cluster_names" {
  description = "Names of the provisioned AKS cluster(s)"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.aks : key => cluster.name
  }
}

output "aks_cluster_ids" {
  description = "Resource IDs of the provisioned AKS cluster(s)"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.aks : key => cluster.id
  }
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID"
  value       = azurerm_log_analytics_workspace.aks.id
}

output "get_credentials_commands" {
  description = "Commands to configure kubectl credentials for your educational cluster(s)"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.aks : key => "az aks get-credentials --resource-group ${azurerm_resource_group.aks.name} --name ${cluster.name} --overwrite-existing"
  }
}
