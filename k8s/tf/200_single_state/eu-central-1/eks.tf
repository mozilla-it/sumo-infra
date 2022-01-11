locals {
  cluster_features = {
    "aws_calico"       = true
    "configmapsecrets" = true
    "external_secrets" = true
    "prometheus"       = true
  }

  node_groups = {
    blue_node_group = {
      desired_capacity = 3,
      disk_size        = 100,
      instance_types   = ["m5.xlarge"],
      max_capacity     = 10,
      min_capacity     = 3,
      subnets          = data.terraform_remote_state.vpc.outputs.private_subnets
    }
  }

  subnet_az = [for s in data.aws_subnet.public : s.availability_zone]
  subnet_id = [for s in data.aws_subnet.public : s.id]
}

module "eks-eu-central-1" {
  source           = "github.com/mozilla-it/terraform-modules//aws/eks?ref=master"
  cluster_name     = "sumo-eks-eu-central-1"
  cluster_version  = "1.21"
  vpc_id           = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_subnets  = data.terraform_remote_state.vpc.outputs.public_subnets
  cluster_features = local.cluster_features
  admin_users_arn  = ["arn:aws:iam::783633885093:role/maws-admin", "arn:aws:iam::517826968395:role/itsre-admin", "arn:aws:iam::095732026120:role/maws-sumo-poweruser"]
  region           = "eu-central-1"
  node_groups      = local.node_groups
}
