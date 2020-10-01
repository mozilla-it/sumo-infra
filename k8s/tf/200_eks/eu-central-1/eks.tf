locals {
  cluster_features = {
    "prometheus"         = false
    "flux"               = true
    "flux_helm_operator" = true
    "external_secrets"   = false
  }

  flux_settings = {
    "git.url"    = "git@github.com:mozilla-it/sumo-infra"
    "git.path"   = "k8s/flux/eu-central-1"
    "git.branch" = "master"
  }

  node_groups = {
    default_node_group = {
      desired_capacity = 3,
      min_capacity     = 3,
      disk_size        = 100,
      max_capacity     = 50,
      instance_type    = "m5.large",
      subnets          = data.terraform_remote_state.vpc.outputs.private_subnets
    }
  }

  subnet_az = [for s in data.aws_subnet.public : s.availability_zone]
  subnet_id = [for s in data.aws_subnet.public : s.id]
}

module "eks-eu-central-1" {
  source                        = "github.com/mozilla-it/terraform-modules//aws/eks?ref=master"
  cluster_name                  = "sumo-eks-eu-central-1"
  cluster_version               = "1.17"
  vpc_id                        = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_subnets               = data.terraform_remote_state.vpc.outputs.public_subnets
  cluster_features              = local.cluster_features
  flux_settings                 = local.flux_settings
  node_groups                   = local.node_groups
  admin_users_arn               = ["arn:aws:iam::783633885093:role/maws-admin", "arn:aws:iam::517826968395:role/itsre-admin"]
  region                        = "eu-central-1"
}
