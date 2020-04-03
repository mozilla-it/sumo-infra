variable "region" {
  default = "us-west-2"
}

variable "s3_kops_state" {
  default = "sumo-kops-state-095732026120"
}

# Tags to apply across the VPC resources
variable "base_tags" {
  default = {
    "Terraform" = "true"
    "Project"   = "sumo"
    "Region"    = "us-west-2"
  }
}

