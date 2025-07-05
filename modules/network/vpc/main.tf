
locals {
  subnet_cidrs         = { for k, az in var.vpc_availiability_zones : az => cidrsubnet(var.vpc_cidr, 8, k) }
  len_public_subnets   = max(length(var.public_subnets))
  len_private_subnets  = max(length(var.private_subnets))
  len_database_subnets = max(length(var.database_subnets))

  max_subnet_length = max(
    local.len_private_subnets,
    local.len_public_subnets,
    local.len_database_subnets,
  )

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = try(aws_vpc_ipv4_cidr_block_association.this[0].vpc_id, aws_vpc.this.id, "")
}

locals {
  public_subnet_ids = aws_subnet.amh_public[*].id
}


resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = merge(
    {
      "Name" = var.vpc_name,
    },
    var.vpc_tags

  )
}

# resource "aws_vpc_dhcp_options" "this" {
#   count = local.create_vpc && var.enable_dhcp_options ? 1 : 0

#   domain_name                       = var.dhcp_options_domain_name
#   domain_name_servers               = var.dhcp_options_domain_name_servers
#   ntp_servers                       = var.dhcp_options_ntp_servers
#   netbios_name_servers              = var.dhcp_options_netbios_name_servers
#   netbios_node_type                 = var.dhcp_options_netbios_node_type
#   ipv6_address_preferred_lease_time = var.dhcp_options_ipv6_address_preferred_lease_time

#   tags = merge(
#     { "Name" = var.name },
#     var.tags,
#     var.dhcp_options_tags,
#   )
# }

# resource "aws_vpc_dhcp_options_association" "this" {
#   count = local.create_vpc && var.enable_dhcp_options ? 1 : 0

#   vpc_id          = local.vpc_id
#   dhcp_options_id = aws_vpc_dhcp_options.this[0].id
# }

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = length(var.secondary_vpc_cidr) > 0 ? length(var.secondary_vpc_cidr) : 0

  # Never use 'local.vpc_id for this
  vpc_id     = aws_vpc.this.id
  cidr_block = element(var.secondary_vpc_cidr, count.index)
}

################################################################################
# Publiс Subnets
################################################################################

locals {
  create_public_subnets = local.len_public_subnets > 0
}

resource "aws_subnet" "amh_public" {
  count = local.len_public_subnets

  vpc_id = local.vpc_id

  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.vpc_availiability_zones, count.index))) > 0 ? element(var.vpc_availiability_zones, count.index) : null
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = try(
        var.public_subnet_names[count.index],
        format(
          "amh-%s-%s",
          var.public_subnet_suffix,
          element(var.vpc_availiability_zones, count.index)
        )
      )
    },
    var.vpc_tags
  )

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig_gateway.id
  }

  tags = merge({ Name : "${var.vpc_name}-${var.public_subnet_suffix}" })
}

resource "aws_route_table_association" "public" {
  count = local.len_public_subnets

  subnet_id      = element(aws_subnet.amh_public[*].id, count.index)
  route_table_id = element(aws_route_table.public[*].id, local.create_public_subnets ? count.index : 0)
}

resource "aws_network_acl" "public" {
  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.amh_public[*].id

  tags = merge(
    { "Name" = "${var.vpc_name}-${var.public_subnet_suffix}" },
  )
}

resource "aws_network_acl_rule" "public_inbound" {
  count = length(var.public_inbound_acl_rules)

  network_acl_id = aws_network_acl.public.id

  egress      = false
  rule_number = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  protocol    = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = length(var.public_outbound_acl_rules)


  network_acl_id = aws_network_acl.public.id

  egress      = true
  rule_number = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  protocol    = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
}


################################################################################
# Private Subnets
################################################################################

locals {
  create_private_subnets = local.len_private_subnets > 0
}

resource "aws_subnet" "amh_private" {
  count = local.len_private_subnets

  vpc_id               = local.vpc_id
  availability_zone    = length(regexall("^[a-z]{2}-", element(var.vpc_availiability_zones, count.index))) > 0 ? element(var.vpc_availiability_zones, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.vpc_availiability_zones, count.index))) == 0 ? element(var.vpc_availiability_zones, count.index) : null

  cidr_block = element(concat(var.private_subnets, [""]), count.index)

  tags = merge(
    {
      Name = try(
        var.private_subnet_names[count.index],
        format(
          "amh-%s-%s",
          var.private_subnet_suffix,
          element(var.vpc_availiability_zones, count.index)
        )
      )
    },
    var.vpc_tags
  )

}


# resource "aws_route_table" "private" {
#     count = local.max_subnet_length
#   vpc_id = aws_vpc.this.id


#     tags = merge({Name: "${var.vpc_name}-${var.private_subnet_suffix}"})
# }

# resource "aws_route_table_association" "private" {
#     count = local.len_private_subnets || 0

#   subnet_id = element(aws_subnet.amh_private[*].id, count.index)
#   route_table_id = element(aws_route_table.private[*].id, local.create_private_subnets? count.index : 0)
# }

# Private Network ACLs

resource "aws_network_acl" "private" {
  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.amh_private[*].id

  tags = merge(
    { "Name" = "${var.vpc_name}-${var.private_subnet_suffix}" },
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  count = length(var.private_inbound_acl_rules)

  network_acl_id = aws_network_acl.private.id

  egress      = false
  rule_number = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  protocol    = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = length(var.private_outbound_acl_rules)

  network_acl_id = aws_network_acl.private.id

  egress      = true
  rule_number = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  protocol    = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
}

# ig_gateway
resource "aws_internet_gateway" "ig_gateway" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.ig_name
  }
}

