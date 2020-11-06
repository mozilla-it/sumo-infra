data "aws_route53_zone" "sumo_mozit_cloud" {
  name = "sumo.mozit.cloud"
}

data "aws_elb" "test_sumo" {
  name = "af97eb50741ba43d18c15dcac62d2dae"
}

resource "aws_route53_record" "test_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "test.sumo.mozit.cloud"
  type    = "A"

  alias {
    name                   = data.aws_elb.test_sumo.dns_name
    zone_id                = data.aws_elb.test_sumo.zone_id
    evaluate_target_health = false
  }
}

data "aws_elb" "dev_sumo" {
  name = "acb4a8e968d624c94b05a3a3c5e5cfa3"
}

resource "aws_route53_record" "dev_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "dev.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = "3660"
  records = [data.aws_elb.dev_sumo.dns_name]
}

data "aws_elb" "stage_frankfurt_sumo" {
  name = "a239fd6aba1964eacbaa125e8138b0d8"
}

resource "aws_route53_record" "stage-frankfurt_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "stage-frankfurt.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = "300"
  records = [data.aws_elb.stage_frankfurt_sumo.dns_name]
}
