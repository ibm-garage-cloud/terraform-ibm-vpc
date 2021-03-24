provider "ibm" {
  generation = 2
  version = ">= 1.8.1"
  region = var.region
}
provider "null" {
}
provider "local" {
}

locals {
  zone_ids         = range(1, var.subnet_count + 1)
  vpc_zone_names   = [ for id in local.zone_ids: "${var.region}-${id}" ]
  prefix_name      = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  vpc_name         = var.name != "" ? var.name : "${local.prefix_name}-vpc"
  vpc_id           = ibm_is_vpc.vpc.id
  subnet_ids       = ibm_is_subnet.vpc_subnet[*].id
  gateway_ids      = var.public_gateway ? ibm_is_public_gateway.vpc_gateway[*].id : [ for val in local.zone_ids: "" ]
  security_group   = ibm_is_vpc.vpc.default_security_group
  ipv4_cidr_blocks = ibm_is_subnet.vpc_subnet[*].ipv4_cidr_block
}

data ibm_resource_group resource_group {
  name = var.resource_group_name
}

resource ibm_is_vpc vpc {
  name           = local.vpc_name
  resource_group = data.ibm_resource_group.resource_group.id
}

resource ibm_is_public_gateway vpc_gateway {
  count = var.public_gateway ? var.subnet_count : 0

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
  count                    = var.subnet_count

  name                     = "${local.vpc_name}-subnet-${format("%02s", count.index)}"
  zone                     = local.vpc_zone_names[count.index]
  vpc                      = local.vpc_id
  public_gateway           = local.gateway_ids[count.index]
  total_ipv4_address_count = 256
  resource_group           = data.ibm_resource_group.resource_group.id
  network_acl              = ibm_is_network_acl.network_acl.id
}

resource ibm_is_security_group_rule rule_tcp_k8s {
  count     = var.subnet_count

  group     = local.security_group
  direction = "inbound"
  remote    = local.ipv4_cidr_blocks[count.index]

  tcp {
    port_min = 30000
    port_max = 32767
  }
}

resource ibm_is_security_group_rule rule_icmp_ping {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
  icmp {
    type = 8
  }
}

# from https://cloud.ibm.com/docs/vpc?topic=vpc-service-endpoints-for-vpc
resource ibm_is_security_group_rule "cse_dns_1" {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "outbound"
  remote    = "161.26.0.10"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource ibm_is_security_group_rule cse_dns_2 {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "outbound"
  remote    = "161.26.0.11"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource ibm_is_security_group_rule private_dns_1 {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "outbound"
  remote    = "161.26.0.7"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource ibm_is_security_group_rule private_dns_2 {
  group     = ibm_is_vpc.vpc.default_security_group
  direction = "outbound"
  remote    = "161.26.0.8"
  udp {
    port_min = 53
    port_max = 53
  }
}
