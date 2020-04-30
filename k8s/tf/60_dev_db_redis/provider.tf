provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-data-dev"
    region = "us-west-2"
  }
}

