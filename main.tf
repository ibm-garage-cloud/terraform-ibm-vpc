
locals {
  prefix_name       = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  vpc_name          = lower(replace(var.name != "" ? var.name : "${local.prefix_name}-vpc", "_", "-"))
  vpc_id            = data.ibm_is_vpc.vpc.id
  security_group_id = data.ibm_is_vpc.vpc.default_security_group
  acl_id            = data.ibm_is_vpc.vpc.default_network_acl
  crn               = data.ibm_is_vpc.vpc.resource_crn
}

resource ibm_is_vpc vpc {
  count = var.provision ? 1 : 0

  name                        = local.vpc_name
  resource_group              = var.resource_group_id
  default_security_group_name = "${local.vpc_name}-security-group"
  default_network_acl_name    = "${local.vpc_name}-acl"
  default_routing_table_name  = "${local.vpc_name}-routing"
}

data ibm_is_vpc vpc {
  depends_on = [ibm_is_vpc.vpc]

  name = local.vpc_name
}

resource ibm_is_network_acl network_acl {
  count      = var.provision ? 1 : 0

  name           = "${local.vpc_name}-acl2"
  resource_group = var.resource_group_id
  vpc            = data.ibm_is_vpc.vpc.id

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



resource "ibm_iam_authorization_policy" "policy" {
  count = length(var.flow-log-cos-bucket-name) > 0 ? 1 : 0
  source_service_name = "is"
  source_resource_type = "flow-log-collector"
  target_service_name = "cloud-object-storage"
  roles = ["Writer"] 
}

resource ibm_is_flow_log flowlog_instance {
  count = length(var.flow-log-cos-bucket-name) > 0 ? 1 : 0
  depends_on = [ibm_is_vpc.vpc]
  name = var.flow-log-cos-bucket-name
  active = true
  //target can be VPC or Virtual Server Instance or Subnet or Primary Network Interface or Secondary Network Interface 
  target = data.ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
  storage_bucket = var.flow-log-cos-bucket-name
}