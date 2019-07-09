provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-cdn"
    region = "us-west-2"
  }
}

####

#####################################################################
# S3 buckets for user media
#####################################################################
resource "aws_s3_bucket" "logs" {
  bucket = "mozit-sumo-user-media-logs"
  acl    = "log-delivery-write"
}

module "sumo-user-media-dev-bucket" {
  bucket_name       = "mozit-sumo-user-media-dev"
  user_media_name   = "static-s3-user-dev"
  iam_policy_name   = "SUMOUserMediaDev"
  logging_bucket_id = "${aws_s3_bucket.logs.id}"
  logging_prefix    = "dev-logs/"
  region            = "${var.region}"
  source            = "./user_media_s3"
}

module "sumo-user-media-stage-bucket" {
  bucket_name       = "mozit-sumo-user-media-stage"
  user_media_name   = "static-s3-user-stage"
  iam_policy_name   = "SUMOUserMediaStage"
  logging_bucket_id = "${aws_s3_bucket.logs.id}"
  logging_prefix    = "stage-logs/"
  region            = "${var.region}"
  source            = "./user_media_s3"
}

module "sumo-user-media-prod-bucket" {
  bucket_name       = "mozit-sumo-user-media-prod"
  user_media_name   = "static-s3-user-prod"
  iam_policy_name   = "SUMOUserMediaProd"
  logging_bucket_id = "${aws_s3_bucket.logs.id}"
  logging_prefix    = "prod-logs/"
  region            = "${var.region}"
  source            = "./user_media_s3"
}

#####################################################################
# S3 buckets for static media
#####################################################################

resource "aws_s3_bucket" "static-media-logs" {
  bucket = "mozit-sumo-static-media-logs"
  acl    = "log-delivery-write"
}

module "sumo-static-media-stage-bucket" {
  bucket_name       = "mozit-sumo-stage-media"
  iam_policy_name   = "SUMOStaticMediaStage"
  logging_bucket_id = "${aws_s3_bucket.static-media-logs.id}"
  logging_prefix    = "stage-logs/"
  region            = "${var.region}"
  source            = "./static_media_s3"
}

module "sumo-static-media-prod-bucket" {
  bucket_name       = "mozit-sumo-prod-media"
  iam_policy_name   = "SUMOStaticMediaProd"
  logging_bucket_id = "${aws_s3_bucket.static-media-logs.id}"
  logging_prefix    = "prod-logs/"
  region            = "${var.region}"
  source            = "./static_media_s3"
}

#####################################################################
# user media CDN
# user media has s3 origins
#####################################################################
module "sumo-user-media-dev-cf" {
  source = "./cloudfront"

  acm_cert_arn      = "arn:aws:acm:us-east-1:095732026120:certificate/e5cfc7ce-87df-4ea4-8007-3c1ef1e9a545"
  short_name        = "user-media-dev-cdn"
  aliases           = ["user-media-dev-cdn.itsre-sumo.mozilla.net", "user-media-dev-cdn.sumo.mozit.cloud"]
  comment           = "Dev CDN for SUMO user media"
  distribution_name = "SUMOMediaDevCDN"
  origin_name       = "mozit-sumo-user-media-dev.s3.us-west-2.amazonaws.com"
  s3_logging_bucket = "mozit-sumo-user-media-logs.s3.us-west-2.amazonaws.com"
  s3_logging_prefix = "cloudfront-user-media-dev"
}

module "sumo-user-media-stage-cf" {
  source = "./cloudfront"

  acm_cert_arn      = "arn:aws:acm:us-east-1:095732026120:certificate/e5cfc7ce-87df-4ea4-8007-3c1ef1e9a545"
  short_name        = "user-media-stage-cdn"
  aliases           = ["user-media-stage-cdn.itsre-sumo.mozilla.net", "user-media-stage-cdn.sumo.mozit.cloud"]
  comment           = "Stage CDN for SUMO user media"
  distribution_name = "SUMOMediaStageCDN"
  origin_name       = "mozit-sumo-user-media-stage.s3.us-west-2.amazonaws.com"
  s3_logging_bucket = "mozit-sumo-user-media-logs.s3.us-west-2.amazonaws.com"
  s3_logging_prefix = "cloudfront-user-media-stage"
}

module "sumo-user-media-prod-cf" {
  source = "./cloudfront"

  acm_cert_arn      = "arn:aws:acm:us-east-1:095732026120:certificate/e5cfc7ce-87df-4ea4-8007-3c1ef1e9a545"
  short_name        = "user-media-prod-cdn"
  aliases           = ["user-media-prod-cdn.itsre-sumo.mozilla.net", "user-media-prod-cdn.sumo.mozit.cloud"]
  comment           = "Prod CDN for SUMO user media"
  distribution_name = "SUMOMediaProdCDN"
  origin_name       = "mozit-sumo-user-media-prod.s3-website-us-west-2.amazonaws.com"
  s3_logging_bucket = "mozit-sumo-user-media-logs.s3.us-west-2.amazonaws.com"
  s3_logging_prefix = "cloudfront-user-media-prod"
}

#####################################################################
# static media CDN
# static media has kitsune as the origin, and kitsune interacts directly with the s3 buckets
#####################################################################
module "sumo-static-media-dev-cf" {
  source = "./cloudfront_static_media"

  acm_cert_arn      = "arn:aws:acm:us-east-1:095732026120:certificate/e5cfc7ce-87df-4ea4-8007-3c1ef1e9a545"
  short_name        = "static-media-dev-cdn"
  aliases           = ["static-media-dev-cdn.itsre-sumo.mozilla.net", "static-media-dev-cdn.sumo.mozit.cloud"]
  comment           = "Dev CDN for SUMO static media"
  distribution_name = "SUMOStaticMediaDevCDN"
  origin_name       = "dev.sumo.mozit.cloud"
  s3_logging_bucket = "mozit-sumo-static-media-logs.s3.us-west-2.amazonaws.com"
  s3_logging_prefix = "cloudfront-static-media-dev"
}

module "sumo-static-media-stage-cf" {
  source = "./cloudfront_static_media"

  acm_cert_arn      = "arn:aws:acm:us-east-1:095732026120:certificate/e5cfc7ce-87df-4ea4-8007-3c1ef1e9a545"
  short_name        = "static-media-stage-cdn"
  aliases           = ["static-media-stage-cdn.itsre-sumo.mozilla.net", "static-media-stage-cdn.sumo.mozit.cloud"]
  comment           = "Stage CDN for SUMO static media"
  distribution_name = "SUMOStaticMediaStageCDN"
  origin_name       = "mozit-sumo-stage-media.s3.us-west-2.amazonaws.com"
  s3_logging_bucket = "mozit-sumo-static-media-logs.s3.us-west-2.amazonaws.com"
  s3_logging_prefix = "cloudfront-static-media-stage"
}

module "sumo-static-media-prod-cf" {
  source = "./cloudfront_static_media"

  acm_cert_arn      = "arn:aws:acm:us-east-1:095732026120:certificate/e5cfc7ce-87df-4ea4-8007-3c1ef1e9a545"
  short_name        = "static-media-prod-cdn"
  aliases           = ["static-media-prod-cdn.itsre-sumo.mozilla.net", "static-media-prod-cdn.sumo.mozit.cloud"]
  comment           = "Prod CDN for SUMO static media"
  distribution_name = "SUMOStaticMediaProdCDN"
  origin_name       = "mozit-sumo-prod-media.s3.us-west-2.amazonaws.com"
  s3_logging_bucket = "mozit-sumo-static-media-logs.s3.us-west-2.amazonaws.com"
  s3_logging_prefix = "cloudfront-static-media-prod"
}

#####################################################################
# failover CDN
#####################################################################
module "sumo-failover-cf" {
  source = "./cloudfront_failover"

  acm_cert_arn      = "arn:aws:acm:us-east-1:095732026120:certificate/58702b44-c7d7-4385-ad0f-56d36aa320c1"
  short_name        = "failover-cdn"
  aliases           = ["support.mozilla.org", "support.mozilla.com", "failover-cdn.sumo.mozit.cloud"]
  comment           = "Frankfurt failover CDN"
  distribution_name = "SUMOFailoverCDN"
  origin_name       = "prod-frankfurt.sumo.mozit.cloud"
  min_ttl           = 0
  max_ttl           = 28800                                                                                 /* 8 hours */
  default_ttl       = 14400                                                                                 /* 4 hours */
  s3_logging_bucket = "mozit-sumo-static-media-logs.s3.us-west-2.amazonaws.com"
  s3_logging_prefix = "sumo-failover-cdn"
}
