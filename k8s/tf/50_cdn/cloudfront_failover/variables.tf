variable "distribution_name" {}
variable "comment" {}
variable "domain_name" {}
variable "acm_cert_arn" {}
variable "default_ttl" {}
variable "min_ttl" {}
variable "max_ttl" {}

variable "aliases" {
  type = "list"
}
