data "aws_route53_zone" "sumo_mozit_cloud" {
  name = "sumo.mozit.cloud"
}

data "aws_elb" "prod_oregon_sumo" {
  name = "afcd59e18d6334565b2eb1e439217b36"
}

resource "aws_route53_record" "prod-oregon_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "prod-oregon.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = "60"
  records = [data.aws_elb.prod_oregon_sumo.dns_name]
}

data "aws_elb" "stage_sumo" {
  name = "af66a7e87cd014b2e8a364f2ee250402"
}

resource "aws_route53_record" "stage_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "stage-oregon.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = "3660"
  records = [data.aws_elb.stage_sumo.dns_name]
}
