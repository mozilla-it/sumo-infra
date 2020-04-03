data "terraform_remote_state" "sumo-prod-us-west-2" {
  backend = "s3"

  config = {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-infra"
    region = "us-west-2"
  }
}

data "aws_caller_identity" "id" {
}

data "aws_network_acls" "default" {
  vpc_id = data.terraform_remote_state.sumo-prod-us-west-2.outputs.vpc_id
}

