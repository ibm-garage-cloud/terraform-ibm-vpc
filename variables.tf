# Resource Group Variables
variable "resource_group_name" {
  type        = string
  description = "The name of the IBM Cloud resource group where the cluster will be created/can be found."
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where the cluster will be/has been installed."
}

variable "name" {
  type        = string
  description = "The name of the vpc instance"
  default     = ""
}

variable "name_prefix" {
  type        = string
  description = "The name of the vpc resource"
  default     = ""
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api token"
}

# VPC Variables
variable "subnets" {
  type        = list(object({
    label = string
  }))
  description = "The labeled subnets that should be created. Each entry in the list represents a different subnet"
  default     = [{
    label = "default"
  }]
}

variable "public_gateway" {
  type        = bool
  description = "Flag indicating that a public gateway should be created"
  default     = true
}

