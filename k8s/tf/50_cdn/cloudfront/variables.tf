variable "distribution_name" {}
variable "comment" {}
variable "origin_name" {}
variable "acm_cert_arn" {}
variable "short_name" {}
variable "s3_logging_bucket" {}
variable "s3_logging_prefix" {}

variable "aliases" {
  type = "list"
}
