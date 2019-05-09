variable "bucket_name" {}
variable "user_media_name" {}
variable "iam_policy_name" {}
variable "logging_bucket_id" {}
variable "logging_prefix" {}
variable "region" {}

variable "hosted-zone-id-defs" {
  # See: https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_website_region_endpoints
  type = "map"

  default = {
    us-east-1 = "Z3AQBSTGFYJSTF"
    us-west-2 = "Z3BJ6K6RIION7M"
  }
}

