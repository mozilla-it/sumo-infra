variable "region" {
  default = "us-west-2"
}

variable "mysql_dev_password" {}

/*
variable "mysql_stage_password" {}
*/
variable "mysql_prod_password" {}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "REGION" {}

variable "AZ" {}
