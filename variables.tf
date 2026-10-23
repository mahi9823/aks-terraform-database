variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region where resources will be created"
}

variable "resource_group_name" {
  type        = string
  default     = "mahesh-aks-edu-rg"
  description = "Name of the Azure Resource Group"
}

variable "aks_clusters" {
  description = "Map of AKS clusters for educational/learning purposes"
  type = map(object({
    name               = string
    dns_prefix         = string
    kubernetes_version = optional(string, "1.36.4")
    node_count         = optional(number, 1)
    vm_size            = optional(string, "Standard_D2s_v4")
    vnet_cidr          = optional(string, "10.20.0.0/16")
    aks_subnet_cidr    = optional(string, "10.20.1.0/24")
    service_cidr       = optional(string, "10.30.0.0/16")
    dns_service_ip     = optional(string, "10.30.0.10")
  }))
}
