locals {
  tags = {
    ManagedBy = "terraform"
    Module    = "vpc"
  }

  route_tables_type = {
    public  = "public"
    private = "private"
  }

  public_subnets = [
    for v in var.template.subnets : v.cidr_block if v.public_subnet
  ]

  private_subnets = [
    for v in var.template.subnets : v.cidr_block if !v.public_subnet
  ]

}

resource "aws_vpc" "this" {
  cidr_block           = var.template.vpc.cidr
  instance_tenancy     = var.template.vpc.tenancy
  enable_dns_support   = var.template.vpc.enable_dns_support
  enable_dns_hostnames = var.template.vpc.enable_dns_hostnames

  tags = {
    Name      = var.template.vpc.name
    ManagedBy = local.tags.ManagedBy
    Module    = local.tags.Module
  }
}

resource "aws_subnet" "this" {
  depends_on = [aws_vpc.this]
  for_each   = { for key, value in var.template.subnets : key => value }

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block

  tags = {
    Name      = each.value.name
    ManagedBy = local.tags.ManagedBy
    Module    = local.tags.Module
    Network   = each.value.public_subnet ? "Public" : "Private"
  }
}

resource "aws_internet_gateway" "this" {
  depends_on = [aws_vpc.this]
  count      = var.template.internet_gateway.enable ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = {
    Name      = var.template.internet_gateway.name
    ManagedBy = local.tags.ManagedBy
    Module    = local.tags.Module
  }
}

resource "aws_eip" "this" {
  depends_on = [aws_subnet.this]
  count      = var.template.nat_gateway.enable ? 1 : 0

  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  depends_on = [aws_eip.this]
  count      = var.template.nat_gateway.enable && length(local.public_subnets) > 0 ? 1 : 0

  allocation_id = aws_eip.this[0].id
  subnet_id     = tolist([for key, subnet in aws_subnet.this : subnet.id if subnet.tags.Network == "Public"])[0]

  tags = {
    Name      = var.template.nat_gateway.name
    ManagedBy = local.tags.ManagedBy
    Module    = local.tags.Module
  }
}

resource "aws_route_table" "this" {
  depends_on = [aws_vpc.this, aws_subnet.this]
  for_each = toset(flatten([
    length(local.public_subnets) > 0 ? [local.route_tables_type.public] : [],
    length(local.private_subnets) > 0 ? [local.route_tables_type.private] : []
  ]))

  vpc_id = aws_vpc.this.id

  tags = {
    Name      = format("eks-%s-rtb", each.value)
    ManagedBy = local.tags.ManagedBy
    Module    = local.tags.Module
  }
}

resource "aws_route_table_association" "this" {
  for_each = {
    for key, value in aws_subnet.this : value.id => {
      subnet_id = value.id
      route_table_id = var.template.subnets[key].public_subnet ? aws_route_table.this[
        local.route_tables_type.public
        ].id : aws_route_table.this[
        local.route_tables_type.private
      ].id
    }
  }

  route_table_id = each.value.route_table_id
  subnet_id      = each.value.subnet_id
}

resource "aws_route" "this" {
  for_each               = { for key, value in var.template.route_table.routes : key => value }
  route_table_id         = aws_route_table.this[each.value.route_table_type].id
  destination_cidr_block = each.value.destination
  gateway_id             = each.value.target.internet_gateway ? aws_internet_gateway.this[0].id : null
  nat_gateway_id         = each.value.target.nat_gateway ? aws_nat_gateway.this[0].id : null
}


data "aws_security_group" "this" {
  for_each = toset(flatten([
    for sgs in var.template.security_groups : [
      for ingress in sgs.ingress_rules : [
        for sg in ingress.security_groups : sg
      ]
    ]
  ]))
  name   = each.value
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group" "this" {
  for_each = { for key, value in var.template.security_groups : key => value }

  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      security_groups = length(ingress.value.security_groups) > 0 ? flatten([
        for data_sg in data.aws_security_group.this : [
          for v in ingress.value.security_groups : data_sg.id if data_sg.name == v
        ]
      ]) : []
      self = ingress.value.self
    }
  }

  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      security_groups = length(egress.value.security_groups) > 0 ? flatten([
        for data_sg in data.aws_security_group.this : [
          for v in egress.value.security_groups : data_sg.id if data_sg.name == v
        ]
      ]) : []
      self = egress.value.self
    }
  }

  tags = {
    Name      = each.value.name
    ManagedBy = local.tags.ManagedBy
    Module    = local.tags.Module
  }

}
