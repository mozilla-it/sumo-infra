data "aws_route53_zone" "sumo_mozit_cloud" {
  name = "sumo.mozit.cloud"
}

data "aws_elb" "stage_sumo" {
  name = "ae7df1f61be8546b3a9d822d231ef1c8"
}

resource "aws_route53_record" "stage_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "stage-oregon.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = "3660"
  records = [data.aws_elb.stage_sumo.dns_name]
}
