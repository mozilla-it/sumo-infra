variable "region" {
  default = "eu-central-1"
}

variable "it_vpn_cidr" {
  type    = list(string)
  default = ["10.48.0.0/15", "10.50.0.0/15"]
}

variable "mysql_dev_password" {
}

/*
variable "mysql_stage_password" {}
*/
