
locals {
  zone_count        = 3
  subnet_count      = length(var.subnets) > 0 ? length(var.subnets) : var.subnet_count
  vpc_zone_names    = [ for index in range(local.subnet_count): "${var.region}-${(index % local.zone_count) + 1}" ]
  prefix_name       = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  vpc_name          = lower(replace(var.name != "" ? var.name : "${local.prefix_name}-vpc", "_", "-"))
  vpc_id            = ibm_is_vpc.vpc.id
  subnet_ids        = ibm_is_subnet.vpc_subnet[*].id
  gateway_ids       = var.public_gateway ? ibm_is_public_gateway.vpc_gateway[*].id : [ for val in range(local.zone_count): "" ]
  security_group_id = ibm_is_vpc.vpc.default_security_group
  ipv4_cidr_blocks  = ibm_is_subnet.vpc_subnet[*].ipv4_cidr_block
  # creates an intermediate object where the key is the label and the value is an array of labels, one for each appearance
  # e.g. [{label = "default"}, {label = "default"}, {label = "test"}] would yield {default = ["default", "default"], test = ["test"]}
  subnet_labels_tmp = { for subnet in var.subnets: subnet.label => subnet.label... }
  # creates an object where the key is the label and the value is number of times the label appears in the original list
  # e.g. {default = ["default", "default"], test = ["test"]} would yield {default = 2, test = 1}
  subnet_label_count = length(var.subnets) > 0 ? {for val in local.subnet_labels_tmp: val => length(local.subnet_labels_tmp[val])} : {default = local.subnet_count}
}

resource null_resource print_names {
  provisioner "local-exec" {
    command = "echo 'Resource group: ${var.resource_group_name}'"
  }
}

data ibm_resource_group resource_group {
  depends_on = [null_resource.print_names]

  name = var.resource_group_name
}

resource ibm_is_vpc vpc {
  name                        = local.vpc_name
  resource_group              = data.ibm_resource_group.resource_group.id
  default_security_group_name = "${local.vpc_name}-security-group"
}

resource ibm_is_public_gateway vpc_gateway {
  count = var.public_gateway ? min(local.zone_count, local.subnet_count) : 0

  name           = "${local.vpc_name}-gateway-${format("%02s", count.index)}"
  vpc            = local.vpc_id
  zone           = local.vpc_zone_names[count.index]
  resource_group = data.ibm_resource_group.resource_group.id

  //User can configure timeouts
  timeouts {
    create = "90m"
  }
}

resource ibm_is_network_acl network_acl {
  name           = "${local.vpc_name}-acl"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.resource_group.id

  rules {
    name        = "egress"
    action      = "allow"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
    direction   = "outbound"
  }
  rules {
    name        = "ingress"
    action      = "allow"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
    direction   = "inbound"
  }
}

resource ibm_is_subnet vpc_subnet {
  count                    = local.subnet_count

  name                     = "${local.vpc_name}-subnet-${format("%02s", count.index)}"
  zone                     = local.vpc_zone_names[count.index]
  vpc                      = local.vpc_id
  public_gateway           = local.gateway_ids[count.index % local.zone_count]
  total_ipv4_address_count = 256
  resource_group           = data.ibm_resource_group.resource_group.id
  network_acl              = ibm_is_network_acl.network_acl.id
}

resource ibm_is_security_group_rule rule_tcp_k8s {
  count     = local.subnet_count

  group     = local.security_group_id
  direction = "inbound"
  remote    = local.ipv4_cidr_blocks[count.index]

  tcp {
    port_min = 30000
    port_max = 32767
  }
}

resource ibm_is_security_group_rule rule_icmp_ping {
  group     = local.security_group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  icmp {
    type = 8
  }
}

# from https://cloud.ibm.com/docs/vpc?topic=vpc-service-endpoints-for-vpc
resource ibm_is_security_group_rule "cse_dns_1" {
  group     = local.security_group_id
  direction = "outbound"
  remote    = "161.26.0.10"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource ibm_is_security_group_rule cse_dns_2 {
  group     = local.security_group_id
  direction = "outbound"
  remote    = "161.26.0.11"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource ibm_is_security_group_rule private_dns_1 {
  group     = local.security_group_id
  direction = "outbound"
  remote    = "161.26.0.7"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource ibm_is_security_group_rule private_dns_2 {
  group     = local.security_group_id
  direction = "outbound"
  remote    = "161.26.0.8"
  udp {
    port_min = 53
    port_max = 53
  }
}
