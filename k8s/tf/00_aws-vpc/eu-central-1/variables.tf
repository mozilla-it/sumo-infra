variable "region" {
  default = "eu-central-1"
}

variable "environment" {
  default = "backup"
}

variable "vpc_cidr" {
  default = "10.142.0.0/16"
}

variable "private_subnets" {
  default = ["10.142.0.0/20", "10.142.32.0/20", "10.142.64.0/20"]
}

variable "public_subnets" {
  default = ["10.142.96.0/19", "10.142.128.0/19", "10.142.160.0/19"]
}

variable "database_subnets" {
  default = ["10.142.16.0/27", "10.142.48.0/27"]
}

variable "elasticache_subnets" {
  default = ["10.142.16.32/27", "10.142.48.32/27"]
}

variable "mdc2-ip" {
  default = "63.245.210.251"
}

variable "mdc2-bgp-asn" {
  default = "65050"
}

# Tags to apply across the VPC resources
variable "base_tags" {
  default = {
    "Terraform"   = "true"
    "Project"     = "sumo"
    "Region"      = "eu-central-1"
    "Environment" = "backup"
  }
}
