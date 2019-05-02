data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-infra"
    region = "us-west-2"
  }
}

# Identify database subnets in our VPC and region
data "aws_subnet_ids" "database" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = {
    Name    = "sumo-prod-db-${var.region}*"
    Purpose = "database"
  }
}

data "aws_security_groups" "kops_sg" {
  filter {
    name   = "group-name"
    values = ["nodes.k8s.${var.region}*.sumo.mozit.cloud"]
  }

  filter {
    name   = "vpc-id"
    values = ["${data.terraform_remote_state.vpc.vpc_id}"]
  }
}
