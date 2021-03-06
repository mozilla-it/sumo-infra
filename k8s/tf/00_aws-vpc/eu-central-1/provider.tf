provider "aws" {
  region  = var.region
  version = "~> 2"
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-infra-eu-central-1"
    region = "us-west-2"
  }
}

