
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

output "zone_names" {
  value       = local.vpc_zone_names
  depends_on  = [ibm_is_subnet.vpc_subnet]
  description = "The list of zone names that into which subnets were created"
}

output "subnet_ids" {
  value       = local.subnet_ids
  depends_on  = [ibm_is_subnet.vpc_subnet]
  description = "The list of subnet ids"
}
