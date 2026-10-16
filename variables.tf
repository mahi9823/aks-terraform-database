variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  type    = string
  default = "East US"
}

variable "resource_group_name" {
  type    = string
  default = "mahesh-aks-prod-rg"
}

variable "aks_clusters" {
  description = "AKS clusters and associated PostgreSQL configuration, keyed by environment"
  type = map(object({
    name                 = string
    dns_prefix           = string
    kubernetes_version   = string
    system_node_count    = number
    system_vm_size       = string
    user_node_count      = number
    user_vm_size         = string
    vnet_cidr            = string
    aks_subnet_cidr      = string
    postgres_subnet_cidr = string
    service_cidr         = string
    dns_service_ip       = string
    postgres_server_name = string
    postgres_admin_login = string
    postgres_sku_name    = string
    postgres_storage_mb  = number
  }))
}
