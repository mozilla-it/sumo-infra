
locals {
  pocket_helpcenter_record = "pocket-helpcenter.sumo.mozit.cloud"
}
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/pocket-helpcenter"
    region = "us-west-2"
  }
}

resource "aws_s3_bucket" "pocket_helpcenter" {
  acl    = "public-read"
  bucket = "pocket-helpcenter-static-media"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

}

data "aws_acm_certificate" "cert" {
  domain = "*.sumo.mozit.cloud"
}

resource "aws_cloudfront_distribution" "pocket_helpcenter" {

  comment         = "Pocket Help Center distribution"
  enabled         = true
  http_version    = "http2"
  is_ipv6_enabled = false
  price_class     = "PriceClass_All"
  aliases         = [local.pocket_helpcenter_record]

  origin {
    origin_id   = "pocket-helpcenter"
    domain_name = aws_s3_bucket.pocket_helpcenter.bucket_regional_domain_name

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = 5
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true
    default_ttl      = 3600
    max_ttl          = 86400
    min_ttl          = 0
    target_origin_id = "pocket-helpcenter"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "https-only"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

data "aws_route53_zone" "sumo_mozit_cloud" {
  name = "sumo.mozit.cloud"
}

resource "aws_route53_record" "pocket_helpcenter" {
  zone_id = data.aws_route53_zone.sumo_mozit_cloud.zone_id
  name    = local.pocket_helpcenter_record
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.pocket_helpcenter.domain_name
    zone_id                = data.aws_route53_zone.sumo_mozit_cloud.zone_id
    evaluate_target_health = false
  }
}

