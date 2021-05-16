
output "name" {
  value       = local.vpc_name
  depends_on  = [null_resource.post_vpc_address_pfx_default, ibm_is_vpc.vpc]
  description = "The name of the vpc instance"
}

output "id" {
  value       = local.vpc_id
  depends_on  = [null_resource.post_vpc_address_pfx_default, ibm_is_vpc.vpc]
  description = "The id of the vpc instance"
}

output "acl_id" {
  value       = local.acl_id
  description = "The id of the network acl"
}

output "crn" {
  value       = local.crn
  depends_on  = [null_resource.post_vpc_address_pfx_default, ibm_is_vpc.vpc]
  description = "The CRN for the vpc instance"
}

output "count" {
  value       = 1
  description = "The number of VPCs created by this module. Always set to 1"
}

output "names" {
  value       = [local.vpc_name]
  depends_on  = [null_resource.post_vpc_address_pfx_default, ibm_is_vpc.vpc]
  description = "The name of the vpc instance"
}

output "ids" {
  value       = [local.vpc_id]
  depends_on  = [null_resource.post_vpc_address_pfx_default, ibm_is_vpc.vpc]
  description = "The id of the vpc instance"
}

output "base_security_group" {
  value       = data.ibm_is_security_group.base.id
  description = "The id of the base security group to be shared by other resources. The base group is different from the default security group."
}

output "addresses" {
  value = data.ibm_is_vpc.vpc.cse_source_addresses[*].address
  description = "The ip address ranges for the VPC"
}
