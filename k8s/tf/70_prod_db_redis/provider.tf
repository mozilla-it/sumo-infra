provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-data"
    region = "us-west-2"
  }
}

