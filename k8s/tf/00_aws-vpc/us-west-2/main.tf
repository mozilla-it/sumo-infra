# Setup main infra in aws for sumo

provider "aws" {
  region  = "${var.region}"
  version = "~> 2"
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-infra"
    region = "us-west-2"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.60.0"

  name = "sumo-${var.environment}"
  cidr = "${var.vpc_cidr}"

  azs = [
    "${data.aws_availability_zones.available.names[0]}",
    "${data.aws_availability_zones.available.names[1]}",
    "${data.aws_availability_zones.available.names[2]}",
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  # For VPN
  enable_vpn_gateway                 = true
  propagate_private_route_tables_vgw = true
  propagate_public_route_tables_vgw  = true

  private_subnets     = "${var.private_subnets}"
  public_subnets      = "${var.public_subnets}"
  database_subnets    = "${var.database_subnets}"
  elasticache_subnets = "${var.elasticache_subnets}"

  private_subnet_tags     = "${merge(map("Purpose", "services"), var.base_tags)}"
  public_subnet_tags      = "${merge(map("Purpose", "kubernetes"), var.base_tags)}"
  database_subnet_tags    = "${merge(map("Purpose", "database"), var.base_tags)}"
  elasticache_subnet_tags = "${merge(map("Purpose", "elasticache"), var.base_tags)}"

  tags = "${var.base_tags}"
}

module "vpn_gateway" {
  source = "terraform-aws-modules/vpn-gateway/aws"

  vpc_id              = "${module.vpc.vpc_id}"
  vpn_gateway_id      = "${module.vpc.vgw_id}"
  customer_gateway_id = "${aws_customer_gateway.main.id}"
  tags                = "${var.base_tags}"
}

resource "aws_customer_gateway" "main" {
  bgp_asn    = "${var.mdc1-bgp-asn}"
  ip_address = "${var.mdc1-ip}"
  type       = "ipsec.1"

  tags = "${merge(map("Name", "mdc1-customer-gateway"), var.base_tags)}"
}