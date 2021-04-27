
output "name" {
  value       = local.vpc_name
  depends_on  = [ibm_is_vpc.vpc]
  description = "The name of the vpc instance"
}

output "id" {
  value       = local.vpc_id
  depends_on  = [ibm_is_vpc.vpc]
  description = "The id of the vpc instance"
}

output "acl_id" {
  value       = local.acl_id
  description = "The id of the network acl"
}

output "crn" {
  value       = local.crn
  depends_on  = [ibm_is_vpc.vpc]
  description = "The CRN for the vpc instance"
}
