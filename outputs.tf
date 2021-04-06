
output "name" {
  value       = local.vpc_name
  depends_on  = [ibm_is_subnet.vpc_subnet]
  description = "The name of the vpc instance"
}

output "id" {
  value       = local.vpc_id
  depends_on  = [ibm_is_subnet.vpc_subnet]
  description = "The id of the vpc instance"
}

output "subnet_count" {
  value       = length(var.subnets)
  description = "The total number of subnets for the vpc"
}

output "subnet_label_count" {
  value       = local.subnet_label_count
  description = "The number of subnets for each label. e.g. {default = 2, test = 1}"
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

output "subnets" {
  value       = local.subnets
  depends_on  = [ibm_is_subnet.vpc_subnet]
  description = "List of subnet objects that contain the subnet id and label, e.g. [{label='', id=''}]"
}
