variable "agent_count" {
  default = 1
}

# The following two variable declarations are placeholder references.
# Set the values for these variable in terraform.tfvars
variable "aks_service_principal_app_id" {
  default = ""
}

variable "aks_service_principal_client_secret" {
  default = ""
}

variable "cluster_name" {
  default = "aks-kubeinvaders"
}

variable "dns_prefix" {
  default = "akskubeinvaders"
}

variable "log_analytics_workspace_location" {
  default = "northeurope"
}

variable "log_analytics_workspace_name" {
  default = "aksLogAnalyticsWorkspace"
}

variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}

variable "resource_group_name" {
  default     = "aks-kubeinvaders"
  description = "Name of the resource group."
}

variable "resource_group_location" {
  default     = "northeurope"
  description = "Location of the resource group."
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}