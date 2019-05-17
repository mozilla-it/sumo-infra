terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-dns"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "${var.region}"
}

resource aws_route53_delegation_set "delegation-set" {
  lifecycle {
    create_before_destroy = true
  }

  reference_name = "${var.reference_name}"
}

resource aws_route53_zone "master-zone" {
  name = "${var.domain_name}"

  delegation_set_id = "${aws_route53_delegation_set.delegation-set.id}"

  tags {
    "Name"    = "${var.domain_name}"
    "Purpose" = "Sumo DNS master zone"
    "Terraform"   = "true"
    "Project"     = "sumo"
  }
}

module "us-west-2" {
  source      = "./hosted_zone"
  region      = "us-west-2"
  domain_name = "${var.domain_name}"
  zone_id     = "${aws_route53_zone.master-zone.id}"
}

module "us-west-2a" {
  source      = "./hosted_zone"
  region      = "us-west-2a"
  domain_name = "${var.domain_name}"
  zone_id     = "${aws_route53_zone.master-zone.id}"
}

module "us-west-2b" {
  source      = "./hosted_zone"
  region      = "us-west-2b"
  domain_name = "${var.domain_name}"
  zone_id     = "${aws_route53_zone.master-zone.id}"
}

module "eu-central-1a" {
  source      = "./hosted_zone"
  region      = "eu-central-1a"
  domain_name = "${var.domain_name}"
  zone_id     = "${aws_route53_zone.master-zone.id}"
}

resource "aws_route53_zone" "cdn" {
  name = "itsre-sumo.mozilla.net"
}
