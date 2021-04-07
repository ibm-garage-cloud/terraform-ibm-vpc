
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
  value       = local.subnet_count
  description = "The total number of subnets for the vpc"
}

output "subnet_label_counts" {
  value       = local.subnet_label_counts
  description = "The number of subnets for each label. e.g. [{label = 'default', count = 2}, {label = 'test', count = 1}]"
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
  value       = [
    for subnet in data.ibm_is_subnet.vpc_subnet:
    {
      id    = subnet.id
      zone  = subnet.zone
      label = length(var.subnets) > 0 ? matchkeys(var.subnets, data.ibm_is_subnet.vpc_subnet[*].id, subnet.id).label : "default"
    }
  ]
  depends_on  = [ibm_is_subnet.vpc_subnet]
  description = "List of subnet objects that contain the subnet id and label, e.g. [{label='', id=''}]"
}
