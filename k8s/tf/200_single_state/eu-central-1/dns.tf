data "aws_route53_zone" "sumo_mozit_cloud" {
  name = "sumo.mozit.cloud"
}

data "aws_elb" "stage_frankfurt_sumo" {
  name = "a13fb08e840fd4f16bbd518816275392"
}

resource "aws_route53_record" "stage-frankfurt_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "stage-frankfurt.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = "300"
  records = [data.aws_elb.stage_frankfurt_sumo.dns_name]
}

data "aws_elb" "dev_sumo" {
  name = "a5a01e97041b042e5a2e14f28c831c44"
}

resource "aws_route53_record" "dev_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "dev.sumo.mozit.cloud"
  type    = "A"

  alias {
    name                   = data.aws_elb.dev_sumo.dns_name
    zone_id                = data.aws_elb.dev_sumo.zone_id
    evaluate_target_health = true
  }
}
