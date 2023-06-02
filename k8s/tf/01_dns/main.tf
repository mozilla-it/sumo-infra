terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-dns"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region
}

resource "aws_route53_delegation_set" "delegation-set" {
  lifecycle {
    create_before_destroy = true
  }

  reference_name = var.reference_name
}

resource "aws_route53_zone" "master-zone" {
  name = var.domain_name

  delegation_set_id = aws_route53_delegation_set.delegation-set.id

  tags = {
    "Name"      = var.domain_name
    "Purpose"   = "Sumo DNS master zone"
    "Terraform" = "true"
    "Project"   = "sumo"
  }
}

resource "aws_route53_zone" "cdn" {
  name = "itsre-sumo.mozilla.net"
}
