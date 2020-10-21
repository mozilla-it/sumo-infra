data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-infra-eu-central-1"
    region = "us-west-2"
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.terraform_remote_state.vpc.outputs.public_subnets)
  id       = each.value
}

data "aws_caller_identity" "current" {}
