# Resource Group Variables
variable "resource_group_id" {
  type        = string
  description = "The id of the IBM Cloud resource group where the VPC instance will be created."
}
variable "resource_group_name" {
  type        = string
  description = "The name of the IBM Cloud resource group where the VPC instance will be created."
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
