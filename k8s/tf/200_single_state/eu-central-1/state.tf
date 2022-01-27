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

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

