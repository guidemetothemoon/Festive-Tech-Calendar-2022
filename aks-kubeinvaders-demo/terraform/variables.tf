# The following two variable declarations are placeholder references.
# Set the values for these variable in terraform.tfvars
variable "aks_service_principal_app_id" {
  type        = string
  default     = ""
  description = "Service Principal application ID"
}

variable "aks_service_principal_client_secret" {
  type        = string
  default     = ""
  description = "Service Principal client secret"
}

variable "resource_group_name" {
  type        = string
  default     = "aks-kubeinvaders"
  description = "Name of the resource group."
}

variable "resource_group_location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "cluster_name" {
  type        = string  
  default     = "aks-kubeinvaders"
  description = "AKS cluster name"
}

variable "dns_prefix" {
  type        = string
  default     = "akskubeinvaders"
  description = "AKS DNS zone prefix"
}

variable "network_address_space" {
  type        = string
  default     = "172.16.0.0/16"
  description = "AKS VNet address space"
}
 
variable "subnet_name" {
  type        = string
  default     = "default"
  description = "AKS subnet name"
}
 
variable "subnet_address_prefix" {
  type        = string
  default     = "172.16.0.0/24"
  description = "AKS subnet address space"
}

variable "agent_count" {
  type        = number
  default     = 1
  description = "Count of VMs to deploy in AKS node pool"
}

variable "log_analytics_workspace_location" {
  type        = string
  default     = "westeurope"
  description = "Location of Log Analytics Workspace"
}

variable "log_analytics_workspace_name" {
  type        = string
  default     = "aksLogAnalyticsWorkspace"
  description = "Log Analytics Workspace name"
}

variable "log_analytics_workspace_sku" {
  type        = string
  default     = "PerGB2018"
  description = "SKU that Log Analytics Workspace will use"
}
 
variable "kubernetes_version" {
  type        = string
  default     = "1.23.12"
  description = "AKS cluster Kubernetes version"
}