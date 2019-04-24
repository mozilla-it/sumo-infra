variable "region" {
  default = "us-west-2"
}

variable "environment" {
  default = "prod"
}

variable "s3_kops_state" {
  default = "sumo-kops-state-095732026120"
}

variable "vpc_cidr" {
  default = "10.141.0.0/16"
}

variable "private_subnets" {
  default = ["10.141.0.0/20", "10.141.32.0/20", "10.141.64.0/20"]
}

variable "public_subnets" {
  default = ["10.141.96.0/19", "10.141.128.0/19", "10.141.160.0/19"]
}

variable "database_subnets" {
  default = ["10.141.16.0/27", "10.141.48.0/27"]
}

variable "elasticache_subnets" {
  default = ["10.141.16.32/27", "10.141.48.32/27"]
}

variable "mdc1-ip" {
  default = "63.245.208.251"
}

variable "mdc1-bgp-asn" {
  default = "65048"
}

# Tags to apply across the VPC resources
variable "base_tags" {
  default = {
    "Terraform" = "true"
    "Project"   = "sumo"
    "Region"    = "us-west-2"
  }
}
