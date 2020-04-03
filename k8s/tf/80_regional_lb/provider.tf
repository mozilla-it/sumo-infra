provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/k8s-nodeport"
    region = "us-west-2"
  }
}

