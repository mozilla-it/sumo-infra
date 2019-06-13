variable "distribution_name" {}
variable "comment" {}
variable "origin_name" {}
variable "acm_cert_arn" {}
variable "default_ttl" {}
variable "min_ttl" {}
variable "max_ttl" {}
variable "short_name" {}

variable "aliases" {
  type = "list"
}
