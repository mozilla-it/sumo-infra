resource "aws_cloudfront_distribution" "sumo-cf-dist" {
  aliases         = "${var.aliases}"
  comment         = "${var.comment}"
  enabled         = true
  http_version    = "http2"
  is_ipv6_enabled = false
  price_class     = "PriceClass_All"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    default_ttl     = "${var.default_ttl}"

    max_ttl                = "${var.max_ttl}"
    min_ttl                = "${var.min_ttl}"
    smooth_streaming       = false
    target_origin_id       = "${var.distribution_name}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = "${var.origin_name}"
    origin_id   = "${var.distribution_name}"

    custom_header = {
      name  = "X-Forwarded-Host"
      value = "support.mozilla.org"
    }

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = 5
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.acm_cert_arn}"
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }

  tags = {
    "Terraform" = "true"
    "Project"   = "sumo"
  }
}

# Create a CNAME for this CDN alias in the master zone, sumo.mozit.cloud
resource "aws_route53_record" "mozit_cname" {
  zone_id = "${data.terraform_remote_state.dns.master-zone}"
  name    = "${var.short_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_cloudfront_distribution.sumo-cf-dist.domain_name}"]
}

# Create a CNAME for this CDN alias in the itsre-sumo.mozilla.net zone
resource "aws_route53_record" "mozilla_net_cname" {
  zone_id = "${data.terraform_remote_state.dns.cdn-zone-id}"
  name    = "${var.short_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_cloudfront_distribution.sumo-cf-dist.domain_name}"]
}
