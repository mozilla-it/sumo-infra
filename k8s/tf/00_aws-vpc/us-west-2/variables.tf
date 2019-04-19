variable "region" {
  default = "us-west-2"
}

variable "environment" {
  default = "stage"
}

variable "private_subnets" {
  default = ["10.0.0.0/19", "10.0.64.0/19", "10.0.128.0/19"]
}

variable "public_subnets" {
  default  = ["10.0.32.0/19", "10.0.96.0/19", "10.0.160.0/19"]
}
