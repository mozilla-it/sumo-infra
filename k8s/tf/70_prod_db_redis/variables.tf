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
  default = [
    "34.168.73.11/32", # prod
    "35.247.21.66/32"  # stage
  ]
  description = "IP addresses of Cloud SQL replicas of SUMO Database. See https://mana.mozilla.org/wiki/pages/viewpage.action?pageId=169419933"
  type        = list(string)
}
