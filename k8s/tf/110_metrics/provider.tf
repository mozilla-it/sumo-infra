terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-metrics"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "${var.region}"
}

