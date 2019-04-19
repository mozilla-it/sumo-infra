# Setup main infra in aws for sumo

provider "aws" {
  region = "${var.region}"
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
  version = "1.46.0"

  name = "kubernetes-${var.environment}-${var.region}"
  cidr = "10.0.0.0/16"

  azs = [
    "${data.aws_availability_zones.available.names[0]}",
    "${data.aws_availability_zones.available.names[1]}",
    "${data.aws_availability_zones.available.names[2]}",
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnets = "${var.private_subnets}"
  public_subnets = "${var.public_subnets}"

  tags = {
    "Environment" = "${var.environment}"
    "app"         = "sumo"
  }
}

resource "aws_s3_bucket" "sumo-kops-state" {
  bucket = "sumo-kops-state-095732026120"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    "Environment" = "${var.environment}"
    "app"         = "sumo"
  }
}
