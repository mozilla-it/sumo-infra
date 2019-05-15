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
    bucket_name = "mozit-sumo-user-media-dev"
    user_media_name = "static-s3-user-dev"
    iam_policy_name = "SUMOUserMediaDev"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "dev-logs/"
    region = "${var.region}"
    source = "./user_media_s3"
}

module "sumo-user-media-stage-bucket" {
    bucket_name = "mozit-sumo-user-media-stage"
    user_media_name = "static-s3-user-stage"
    iam_policy_name = "SUMOUserMediaStage"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "stage-logs/"
    region = "${var.region}"
    source = "./user_media_s3"
}

module "sumo-user-media-prod-bucket" {
    bucket_name = "mozit-sumo-user-media-prod"
    user_media_name = "static-s3-user-prod"
    iam_policy_name = "SUMOUserMediaProd"
    logging_bucket_id = "${aws_s3_bucket.logs.id}"
    logging_prefix = "prod-logs/"
    region = "${var.region}"
    source = "./user_media_s3"
}

#####################################################################
# S3 buckets for static media
#####################################################################

resource "aws_s3_bucket" "static-media-logs" {
  bucket = "mozit-sumo-static-media-logs"
  acl    = "log-delivery-write"
}

module "sumo-static-media-stage-bucket" {
    bucket_name = "mozit-sumo-stage-media"
    iam_policy_name = "SUMOStaticMediaStage"
    logging_bucket_id = "${aws_s3_bucket.static-media-logs.id}"
    logging_prefix = "stage-logs/"
    region = "${var.region}"
    source = "./static_media_s3"
}

module "sumo-static-media-prod-bucket" {
    bucket_name = "mozit-sumo-prod-media"
    iam_policy_name = "SUMOStaticMediaProd"
    logging_bucket_id = "${aws_s3_bucket.static-media-logs.id}"
    logging_prefix = "prod-logs/"
    region = "${var.region}"
    source = "./static_media_s3"
}

#####################################################################
# user media CDN
#####################################################################
module "sumo-user-media-dev-cf" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:095732026120:certificate/c948200c-e483-4d31-aeb8-1b5cfc9ab18f"
    aliases = ["dev-media-cdn.sumo.mozit.cloud"]
    comment = "Dev CDN for SUMO user media"
    distribution_name = "SUMOMediaDevCDN"
    domain_name = "mozit-sumo-user-media-dev.s3-website-us-west-2.amazonaws.com"
}

module "sumo-user-media-stage-cf" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:095732026120:certificate/c948200c-e483-4d31-aeb8-1b5cfc9ab18f"
    aliases = ["stage-media-cdn.sumo.mozit.cloud"]
    comment = "Stage CDN for SUMO user media"
    distribution_name = "SUMOMediaStageCDN"
    domain_name = "mozit-sumo-user-media-stage.s3-website-us-west-2.amazonaws.com"
}

module "sumo-user-media-prod-cf" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:095732026120:certificate/c948200c-e483-4d31-aeb8-1b5cfc9ab18f"
    aliases = ["prod-media-cdn.sumo.mozit.cloud"]
    comment = "Prod CDN for SUMO user media"
    distribution_name = "SUMOMediaProdCDN"
    domain_name = "mozit-sumo-user-media-prod.s3-website-us-west-2.amazonaws.com"
}

#####################################################################
# static media CDN
#####################################################################
module "sumo-static-media-dev-cf" {
    source = "./cloudfront_static_media"

    acm_cert_arn = "arn:aws:acm:us-east-1:095732026120:certificate/c948200c-e483-4d31-aeb8-1b5cfc9ab18f"
    aliases = ["static-media-dev-cdn.sumo.mozit.cloud"]
    comment = "Dev CDN for SUMO static media"
    distribution_name = "SUMOStaticMediaDevCDN"
    domain_name = "dev.sumo.mozit.cloud"
}

module "sumo-static-media-stage-cf" {
    source = "./cloudfront_static_media"

    acm_cert_arn = "arn:aws:acm:us-east-1:095732026120:certificate/c948200c-e483-4d31-aeb8-1b5cfc9ab18f"
    aliases = ["static-media-stage-cdn.sumo.mozit.cloud"]
    comment = "Stage CDN for SUMO static media"
    distribution_name = "SUMOStaticMediaStageCDN"
    domain_name = "stage.sumo.mozit.cloud"
}

module "sumo-static-media-prod-cf" {
    source = "./cloudfront_static_media"

    acm_cert_arn = "arn:aws:acm:us-east-1:095732026120:certificate/c948200c-e483-4d31-aeb8-1b5cfc9ab18f"
    aliases = ["static-media-prod-cdn.sumo.mozit.cloud"]
    comment = "Prod CDN for SUMO static media"
    distribution_name = "SUMOStaticMediaProdCDN"
    domain_name = "prod.sumo.mozit.cloud"
}

#####################################################################
# failover CDN
#####################################################################
module "sumo-failover-cf" {
    source = "./cloudfront_failover"

    acm_cert_arn = "arn:aws:acm:us-east-1:095732026120:certificate/c948200c-e483-4d31-aeb8-1b5cfc9ab18f"
    aliases = ["failover-cdn.sumo.mozit.cloud"]
    comment = "Frankfurt failover CDN"
    distribution_name = "SUMOFailoverCDN"
    domain_name = "prod-frankfurt.sumo.mozit.cloud"
    min_ttl = 0
    max_ttl = 28800     /* 8 hours */
    default_ttl = 14400 /* 4 hours */
}
