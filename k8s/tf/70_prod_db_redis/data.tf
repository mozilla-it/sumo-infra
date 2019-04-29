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

# Identify elasticache/redis subnets in our VPC and region
data "aws_subnet_ids" "elasticache" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = {
    Name    = "sumo-prod-elasticache-${var.region}*"
    Purpose = "elasticache"
  }
}

# Get a list of databse subnet objects in our VPC and region
data "aws_subnet" "database" {
  count = "${length(data.aws_subnet_ids.database.ids)}"
  id    = "${data.aws_subnet_ids.database.ids[count.index]}"
}

# Get k8s security groups created by kops
data "terraform_remote_state" "kops" {
  backend = "s3"

  config {
    bucket = "sumo-kops-state-095732026120"
    key    = "terraform/sumo-infra"
    region = "us-west-2"
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
