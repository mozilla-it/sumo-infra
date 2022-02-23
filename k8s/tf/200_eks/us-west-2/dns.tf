data "aws_route53_zone" "sumo_mozit_cloud" {
  name = "sumo.mozit.cloud"
}

data "aws_elb" "prod_oregon_sumo" {
  name = "sumo-prod-regional-lb"
}

resource "aws_route53_record" "prod-oregon_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "prod-oregon.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = "60"
  records = [data.aws_elb.prod_oregon_sumo.dns_name]
}

data "aws_lb" "stage_sumo" {
  name = "k8s-sumostag-sumostag-6fda13f35c"
}

resource "aws_route53_record" "stage_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "stage-oregon.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = "3660"
  records = [data.aws_lb.stage_sumo.dns_name]
}
