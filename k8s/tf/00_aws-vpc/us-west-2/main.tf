# Setup main infra in aws for sumo

provider "aws" {
  region = "${var.region}"
  version = "~> 2"
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/vpc-test"
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

  private_subnets = "${var.private_subnets}"
  public_subnets = "${var.public_subnets}"
  database_subnets = "${var.database_subnets}"
  elasticache_subnets = "${var.elasticache_subnets}"

  private_subnet_tags = "${merge(map("Purpose", "services"), var.base_tags)}"
  public_subnet_tags = "${merge(map("Purpose", "kubernetes"), var.base_tags)}"
  database_subnet_tags = "${merge(map("Purpose", "database"), var.base_tags)}"
  elasticache_subnet_tags = "${merge(map("Purpose", "elasticache"), var.base_tags)}"

  tags = "${var.base_tags}"

}

resource "aws_s3_bucket" "sumo-kops-state" {
  bucket = "${var.s3_kops_state}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = "${var.base_tags}"
}
