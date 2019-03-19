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

  private_subnets = ["10.0.0.0/19", "10.0.64.0/19", "10.0.128.0/19"]
  public_subnets  = ["10.0.32.0/19", "10.0.96.0/19", "10.0.160.0/19"]

  tags = {
    "Environment" = "${var.environment}"
    "app"         = "sumo"
  }
}

resource "aws_kms_key" "s3_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "sumo-kops-state" {
  bucket = "sumo-kops-state-095732026120"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    "Environment" = "${var.environment}"
    "app"         = "sumo"
  }
}
