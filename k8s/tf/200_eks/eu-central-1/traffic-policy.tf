resource "aws_route53_health_check" "stage" {
  fqdn              = "stage-frankfurt.sumo.mozit.cloud"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/readiness/"
  failure_threshold = "3"
  request_interval  = "30"
  enable_sni        = true

  tags = {
    Name = "Sumo Stage eu-central-1 EKS"
  }
}

resource "aws_cloudwatch_metric_alarm" "stage_lb_dns_name" {
  provider            = aws.us-east-1
  alarm_name          = "Sumo_Stage_eu-central-1-awsroute53"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  treat_missing_data  = "missing"
  alarm_description   = "Monitor Stage EKS eu-central-1 health"

  actions_enabled = "true"
  alarm_actions   = ["arn:aws:sns:us-east-1:095732026120:MozillaSumoSlack"]

  dimensions = {
    HealthCheckId = aws_route53_health_check.stage.id
  }
}

resource "aws_route53_health_check" "prod" {
  fqdn              = "prod-frankfurt.sumo.mozit.cloud"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/readiness/"
  failure_threshold = "3"
  request_interval  = "30"
  enable_sni        = true

  tags = {
    Name = "Sumo Prod eu-central-1 EKS"
  }
}

resource "aws_cloudwatch_metric_alarm" "prod_lb_dns_name" {
  provider            = aws.us-east-1
  alarm_name          = "Sumo_Prod_eu-central-1-awsroute53"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  treat_missing_data  = "missing"
  alarm_description   = "Monitor Prod EKS eu-central-1 health"

  actions_enabled = "true"
  alarm_actions   = ["arn:aws:sns:us-east-1:095732026120:MozillaSumoSlack"]

  dimensions = {
    HealthCheckId = aws_route53_health_check.prod.id
  }
}