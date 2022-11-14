variable "resource_group_location" {
  type = string
  default     = "westeurope"
  description = "Location of the resource group."
  sensitive = false
}

variable "resource_group_name" {
  type = string
  description = "Resource Group Name."
  sensitive = false
}