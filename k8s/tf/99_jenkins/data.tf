data terraform_remote_state "sumo-prod-us-west-2" {
  backend = "s3"

  config {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-infra"
    region = "us-west-2"
  }
}

data aws_subnet_ids "subnet_id" {
  vpc_id = "${data.terraform_remote_state.sumo-prod-us-west-2.vpc_id}"

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data aws_ami "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data aws_acm_certificate "ci" {
  domain   = "${var.acm_cert}"
  statuses = ["ISSUED"]
}

data "aws_caller_identity" "id" {}
