data "aws_route53_zone" "sumo_mozit_cloud" {
  name = "sumo.mozit.cloud"
}

data "aws_lb" "prod_oregon_sumo" {
  name = "k8s-sumoprod-sumoprod-6008bc7924"
}

resource "aws_route53_record" "prod-oregon_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "prod-oregon.sumo.mozit.cloud"
  type    = "A"
  alias {
    name = data.aws_lb.prod_oregon_sumo.dns_name
    zone_id = data.aws_lb.prod_oregon_sumo.zone_id
    evaluate_target_health = false
  }
}

data "aws_lb" "stage_sumo" {
  name = "k8s-sumostag-sumostag-6fda13f35c"
}

resource "aws_route53_record" "stage_sumo_mozit_cloud" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = "stage-oregon.sumo.mozit.cloud"
  type    = "A"
  alias {
    name = data.aws_lb.stage_sumo.dns_name
    zone_id = data.aws_lb.stage_sumo.zone_id
    evaluate_target_health = false
  }
}
