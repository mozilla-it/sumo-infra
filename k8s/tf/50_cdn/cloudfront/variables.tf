variable "distribution_name" {}
variable "comment" {}
variable "domain_name" {}
variable "acm_cert_arn" {}
variable "short_name" {}

variable "aliases" {
  type = "list"
}
