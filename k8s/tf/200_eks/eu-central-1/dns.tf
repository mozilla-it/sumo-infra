data "aws_route53_zone" "sumo_mozit_cloud" {
  name = "sumo.mozit.cloud"
}

data "aws_lb" "prod_frankfurt_sumo" {
  name = "k8s-sumoprod-sumoprod-5ce65857f0"
}

resource "aws_route53_record" "prod-frankfurt_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "prod-frankfurt.sumo.mozit.cloud"
  type    = "A"
  alias {
    name                   = data.aws_lb.prod_frankfurt_sumo.dns_name
    zone_id                = data.aws_lb.prod_frankfurt_sumo.zone_id
    evaluate_target_health = false
  }
}

data "aws_lb" "stage_frankfurt_sumo" {
  name = "k8s-sumostag-sumostag-7336d33c18"
}

resource "aws_route53_record" "stage-frankfurt_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "stage-frankfurt.sumo.mozit.cloud"
  type    = "A"
  alias {
    name                   = data.aws_lb.stage_frankfurt_sumo.dns_name
    zone_id                = data.aws_lb.stage_frankfurt_sumo.zone_id
    evaluate_target_health = false
  }
}

data "aws_lb" "dev_sumo" {
  name = "k8s-sumodev-sumodevi-1d923af160"
}

resource "aws_route53_record" "dev_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "dev.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = "300"
  records = [data.aws_lb.dev_sumo.dns_name]
}
