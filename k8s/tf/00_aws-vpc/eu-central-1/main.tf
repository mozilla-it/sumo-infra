module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name = "sumo-${var.environment}"
  cidr = var.vpc_cidr

  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2],
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  # For VPN
  enable_vpn_gateway                 = true
  propagate_private_route_tables_vgw = true
  propagate_public_route_tables_vgw  = true

  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  database_subnets    = var.database_subnets
  elasticache_subnets = var.elasticache_subnets

  private_subnet_tags = merge(
    {
      "Purpose"                                     = "services",
      "kubernetes.io/cluster/sumo-eks-eu-central-1" = "shared"
    },
    var.base_tags,
  )
  public_subnet_tags = merge(
    {
      "Purpose" = "kubernetes",
      "kubernetes.io/cluster/sumo-eks-eu-central-1" = "shared"
    },
    var.base_tags,
  )
  database_subnet_tags = merge(
    {
      "Purpose" = "database"
    },
    var.base_tags,
  )
  elasticache_subnet_tags = merge(
    {
      "Purpose" = "elasticache"
    },
    var.base_tags,
  )

  tags = var.base_tags
}

module "vpn_gateway" {
  source = "terraform-aws-modules/vpn-gateway/aws"

  vpc_id              = module.vpc.vpc_id
  vpn_gateway_id      = module.vpc.vgw_id
  customer_gateway_id = aws_customer_gateway.main.id
  tags = merge(
    {
      "Purpose" = "EU-to-MDC2"
    },
    var.base_tags,
  )
}

resource "aws_customer_gateway" "main" {
  bgp_asn    = var.mdc2-bgp-asn
  ip_address = var.mdc2-ip
  type       = "ipsec.1"

  tags = merge(
    {
      "Name" = "mdc2-customer-gateway"
    },
    var.base_tags,
  )
}

module "vpn_gateway_mdc1" {
  source = "terraform-aws-modules/vpn-gateway/aws"

  vpc_id              = module.vpc.vpc_id
  vpn_gateway_id      = module.vpc.vgw_id
  customer_gateway_id = aws_customer_gateway.mdc1.id
  tags = merge(
    {
      "Purpose" = "EU-to-MDC1"
    },
    var.base_tags,
  )
}

resource "aws_customer_gateway" "mdc1" {
  bgp_asn    = var.mdc1-bgp-asn
  ip_address = var.mdc1-ip
  type       = "ipsec.1"

  tags = merge(
    {
      "Name" = "mdc1-customer-gateway"
    },
    var.base_tags,
  )
}

