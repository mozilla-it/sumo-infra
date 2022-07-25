variable "region" {
  default = "us-west-2"
}

variable "it_vpn_cidr" {
  # MDC1
  default = "10.48.0.0/15"
}

variable "mysql_prod_password" {
}

# see https://github.com/mozilla-services/cloudops-infra/pull/4216
variable "cloud_sql_cidr" {
  default = "34.173.94.217/32"
}
