
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

  ++++++++++
  
    #### ACL Outboud #######
  rules {
    name        = "eg-acl-http"
    action      = "allow"
    source      = "10.0.0.0/8"
    destination = "0.0.0.0/0"
    direction   = "outbound"
    tcp {
      port_max        = 80
      port_min        = 80
      source_port_max = 80
      source_port_min = 80
    }
  }

  rules {
    name        = "eg-acl-https"
    action      = "allow"
    source      = "10.0.0.0/8"
    destination = "0.0.0.0/0"
    direction   = "outbound"
    tcp {
      port_max        = 443
      port_min        = 443
      source_port_max = 443
      source_port_min = 443
    }
  }
  rules {
    name        = "eg-acl-ssh"
    action      = "allow"
    source      = "10.0.0.0/8"
    destination = "0.0.0.0/0"
    direction   = "outbound"
    tcp {
      port_max        = 22
      port_min        = 22
      source_port_max = 22
      source_port_min = 22
    }
  }
  rules {
    name        = "eg-acl-ovpn"
    action      = "allow"
    source      = "10.0.0.0/8"
    destination = "0.0.0.0/0"
    direction   = "outbound"
    tcp {
      port_max        = 1194
      port_min        = 1194
      source_port_max = 1194
      source_port_min = 1194
    }
  }

  rules {
    name        = "eg-internal"
    action      = "allow"
    source      = "10.0.0.0/8"
    destination = "10.0.0.0/8"
    direction   = "outbound"
  }

    #### ACL Inboud #######

  rules {
    name        = "in-acl-http"
    action      = "allow"
    source      = "0.0.0.0/0"
    destination = "10.0.0.0/8"
    direction   = "inbound"
    tcp {
      port_max        = 80
      port_min        = 80
      source_port_max = 80
      source_port_min = 80
    }
  }

  rules {
    name        = "in-acl-https"
    action      = "allow"
    source      = "0.0.0.0/0"
    destination = "10.0.0.0/8"
    direction   = "inbound"
    tcp {
      port_max        = 443
      port_min        = 443
      source_port_max = 443
      source_port_min = 443
    }
  }


  rules {
    name        = "eg-internal1"
    action      = "allow"
    source      = "10.0.0.0/8"
    destination = "10.0.0.0/8"
    direction   = "inbound"
  }

  rules {
    name        = "in-acl-ssh"
    action      = "allow"
    source      = "0.0.0.0/0"
    destination = "10.0.0.0/8"
    direction   = "inbound"
    tcp {
      port_max        = 22
      port_min        = 22
      source_port_max = 22
      source_port_min = 22

    }
  }
  rules {
    name        = "in-acl-ovpn"
    action      = "allow"
    source      = "0.0.0.0/0"
    destination = "10.0.0.0/8"
    direction   = "inbound"
    tcp {
      port_max        = 1194
      port_min        = 1194
      source_port_max = 1194
      source_port_min = 1194

    }
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

resource ibm_is_flow_log flowlog_instance {
  count = length(var.flow_log_cos_bucket_name) > 0 ? 1 : 0
  depends_on = [ibm_is_vpc.vpc]
  name = "${local.vpc_name}-flowlog"
  active = true
  //target can be VPC or Virtual Server Instance or Subnet or Primary Network Interface or Secondary Network Interface 
  target = data.ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
  storage_bucket = var.flow_log_cos_bucket_name
}

