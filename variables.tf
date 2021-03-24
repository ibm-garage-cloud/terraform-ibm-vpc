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
variable "subnet_count" {
  type        = number
  description = "Number of subnets for region"
  default     = 1
}

variable "public_gateway" {
  type        = bool
  description = "Flag indicating that a public gateway should be created"
  default     = true
}

