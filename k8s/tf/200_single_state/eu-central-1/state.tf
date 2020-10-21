terraform {
  required_version = ">= 0.12"
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/eu-central-1/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "eu-central-1"
}
