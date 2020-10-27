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

