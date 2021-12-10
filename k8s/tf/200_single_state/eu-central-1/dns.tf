data "aws_route53_zone" "sumo_mozit_cloud" {
  name = "sumo.mozit.cloud"
}

data "aws_elb" "stage_frankfurt_sumo" {
  name = "a9777a701750711eba90202d989fd40b"
}

resource "aws_route53_record" "stage-frankfurt_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "stage-frankfurt.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = "300"
  records = [data.aws_elb.stage_frankfurt_sumo.dns_name]
}
