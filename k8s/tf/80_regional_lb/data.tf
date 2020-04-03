data "terraform_remote_state" "sumo-prod-us-west-2" {
  backend = "s3"

  config = {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-infra"
    region = "us-west-2"
  }
}

data "aws_autoscaling_groups" "group-a" {
  filter {
    name   = "key"
    values = ["Name"]
  }

  filter {
    name   = "value"
    values = ["nodes.k8s.us-west-2a.sumo.mozit.cloud"]
  }
}

data "aws_autoscaling_groups" "group-b" {
  filter {
    name   = "key"
    values = ["Name"]
  }

  filter {
    name   = "value"
    values = ["nodes.k8s.us-west-2b.sumo.mozit.cloud"]
  }
}

data "aws_security_group" "nodes-a" {
  vpc_id = data.terraform_remote_state.sumo-prod-us-west-2.outputs.vpc_id

  tags = {
    "Name" = "nodes.k8s.us-west-2a.sumo.mozit.cloud"
  }
}

data "aws_security_group" "nodes-b" {
  vpc_id = data.terraform_remote_state.sumo-prod-us-west-2.outputs.vpc_id

  tags = {
    "Name" = "nodes.k8s.us-west-2b.sumo.mozit.cloud"
  }
}

