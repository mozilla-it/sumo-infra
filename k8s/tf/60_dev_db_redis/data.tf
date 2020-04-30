data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-infra-eu-central-1"
    region = "us-west-2"
  }
}

# Identify database subnets in our VPC and region
data "aws_subnet_ids" "database" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name    = "sumo-backup-db-${var.region}*"
    Purpose = "database"
  }
}

# Identify elasticache/redis subnets in our VPC and region
data "aws_subnet_ids" "elasticache" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name    = "sumo-backup-elasticache-${var.region}*"
    Purpose = "elasticache"
  }
}

# Get a list of databse subnet objects in our VPC and region
data "aws_subnet" "database" {
   for_each = data.aws_subnet_ids.database.ids
   id    = each.value

}

data "aws_security_groups" "kops_sg" {
  filter {
    name   = "group-name"
    values = ["nodes.k8s.${var.region}*.sumo.mozit.cloud"]
  }

  filter {
    name = "vpc-id"
    values = [data.terraform_remote_state.vpc.outputs.vpc_id]
  }
}

