
locals {
  tmp_dir           = "${path.cwd}/.tmp"
  zone_count        = 3
  vpc_zone_names    = [ for index in range(local.zone_count): "${var.region}-${(index % local.zone_count) + 1}" ]
  prefix_name       = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  vpc_name          = lower(replace(var.name != "" ? var.name : "${local.prefix_name}-vpc", "_", "-"))
  vpc_id            = data.ibm_is_vpc.vpc.id
  security_group_id = data.ibm_is_vpc.vpc.default_security_group
  acl_id            = data.ibm_is_vpc.vpc.default_network_acl
  crn               = data.ibm_is_vpc.vpc.resource_crn
  ipv4_cidr_provided = length(var.address_prefixes) >= var.address_prefix_count
  ipv4_cidr_block    = local.ipv4_cidr_provided ? var.address_prefixes : [ for val in range(var.address_prefix_count): "" ]
  address_prefix_management = local.ipv4_cidr_provided ? "manual" : "auto"
  provision_cidr     = var.provision && local.ipv4_cidr_provided
}

resource null_resource print_values {
  provisioner "local-exec" {
    command = "echo 'Bucket name: ${var.flow_log_cos_bucket_name != null ? var.flow_log_cos_bucket_name : ""}'"
  }
  provisioner "local-exec" {
    command = "echo 'Auth policy id: ${var.auth_id}'"
  }
}

resource ibm_is_vpc_address_prefix cidr_prefix {
  count = local.provision_cidr ? var.address_prefix_count : 0

  name  = "${local.vpc_name}-cidr-${format("%02s", count.index)}"
  zone  = local.vpc_zone_names[count.index]
  vpc   = data.ibm_is_vpc.vpc.id
  cidr  = local.ipv4_cidr_block[count.index]
}

resource ibm_is_vpc vpc {
  count = var.provision ? 1 : 0

  name                        = local.vpc_name
  resource_group              = var.resource_group_id
  address_prefix_management   = local.address_prefix_management
  default_security_group_name = "${local.vpc_name}-security-group"
  default_network_acl_name    = "${local.vpc_name}-acl"
  default_routing_table_name  = "${local.vpc_name}-routing"
}

# Set the address prefixes as the default.  This will allow us to specify the number of ips required
# in each subnet, instead of figuring out specific cidrs.
# Note the "split" function call - this is because the id returned from creating the address
# comes back as <vpc_id>/<address_range_id> and the update call wants these passed as separate
# arguments.  I suspect this is actually a defect in what is returned from ibm_is_vpc_address_prefix
# and it may one day be fixed and trip up this code.
resource null_resource post_vpc_address_pfx_default {
  count = local.provision_cidr ? var.address_prefix_count : 0
  depends_on = [ibm_is_vpc_address_prefix.cidr_prefix]

  provisioner "local-exec" {
    command = <<COMMAND
      ibmcloud login --apikey ${var.ibmcloud_api_key} -r ${var.region} -g ${var.resource_group_name} --quiet ; \
      ibmcloud is vpc-address-prefix-update '${local.provision_cidr ? ibm_is_vpc.vpc[0].id : ""}' '${split("/", local.provision_cidr ? ibm_is_vpc_address_prefix.cidr_prefix[0].id : "/")[1]}' --default true ; \
      ibmcloud is vpc-address-prefix-update '${local.provision_cidr ? ibm_is_vpc.vpc[0].id : ""}' '${split("/", local.provision_cidr ? ibm_is_vpc_address_prefix.cidr_prefix[1].id : "/")[1]}' --default true ; \
      ibmcloud is vpc-address-prefix-update '${local.provision_cidr ? ibm_is_vpc.vpc[0].id : ""}' '${split("/", local.provision_cidr ? ibm_is_vpc_address_prefix.cidr_prefix[2].id : "/")[1]}' --default true ; \
     COMMAND
  }
}

data ibm_is_vpc vpc {
  depends_on = [ibm_is_vpc.vpc]

  name = local.vpc_name
}

resource ibm_is_security_group_rule rule_icmp_ping {
  count = var.provision ? 1 : 0

  group     = local.security_group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  icmp {
    type = 8
  }
}

# from https://cloud.ibm.com/docs/vpc?topic=vpc-service-endpoints-for-vpc
resource ibm_is_security_group_rule "cse_dns_1" {
  count = var.provision ? 1 : 0

  group     = local.security_group_id
  direction = "outbound"
  remote    = "161.26.0.10"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource ibm_is_security_group_rule cse_dns_2 {
  count = var.provision ? 1 : 0

  group     = local.security_group_id
  direction = "outbound"
  remote    = "161.26.0.11"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource ibm_is_security_group_rule private_dns_1 {
  count = var.provision ? 1 : 0

  group     = local.security_group_id
  direction = "outbound"
  remote    = "161.26.0.7"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource ibm_is_security_group_rule private_dns_2 {
  count = var.provision ? 1 : 0

  group     = local.security_group_id
  direction = "outbound"
  remote    = "161.26.0.8"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource ibm_is_flow_log flowlog_instance {
  count = length(var.flow_log_cos_bucket_name) > 0 ? 1 : 0
  depends_on = [ibm_is_vpc.vpc, null_resource.print_values]

  name = "${local.vpc_name}-flowlog"
  active = true
  //target can be VPC or Virtual Server Instance or Subnet or Primary Network Interface or Secondary Network Interface 
  target = data.ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
  storage_bucket = var.flow_log_cos_bucket_name
}

