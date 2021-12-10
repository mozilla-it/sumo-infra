locals {
  cluster_features = {
    "prometheus"         = false
    "flux"               = true
    "flux_helm_operator" = true
    "external_secrets"   = false
  }

  flux_settings = {
    "git.url"    = "git@github.com:mozilla-it/sumo-infra"
    "git.path"   = "k8s/flux/us-west-2"
    "git.branch" = "master"
  }

  worker_groups = [
    {
      name                  = "k8s-worker-green"
      ami_id                = "ami-04f0f3d381d07e0b6"
      asg_desired_capacity  = "1"
      asg_max_size          = "50"
      asg_min_size          = "1"
      autoscaling_enabled   = true
      protect_from_scale_in = true
      instance_type         = "m5.large"
      root_volume_size      = "100"
      subnets               = data.terraform_remote_state.vpc.outputs.private_subnets
      tags = [
        { key : "k8s.io/cluster-autoscaler/enabled", value : "true", propagate_at_launch : "true" },
        { key : "k8s.io/cluster-autoscaler/sumo-eks-us-west-2", value : "true", propagate_at_launch : "true" }
      ]
    },
    {
      name                  = "k8s-worker-blue"
      ami_id                = "ami-04f0f3d381d07e0b6"
      asg_desired_capacity  = "0"
      asg_max_size          = "0"
      asg_min_size          = "0"
      autoscaling_enabled   = true
      protect_from_scale_in = true
      instance_type         = "m5.large"
      root_volume_size      = "100"
      subnets               = data.terraform_remote_state.vpc.outputs.private_subnets
      tags = [
        { key : "k8s.io/cluster-autoscaler/enabled", value : "true", propagate_at_launch : "true" },
        { key : "k8s.io/cluster-autoscaler/sumo-eks-us-west-2", value : "true", propagate_at_launch : "true" }
      ]
    }
  ]

  subnet_az = [for s in data.aws_subnet.public : s.availability_zone]
  subnet_id = [for s in data.aws_subnet.public : s.id]
}

module "eks-us-west-2" {
  source                                             = "github.com/mozilla-it/terraform-modules//aws/eks?ref=master"
  cluster_name                                       = "sumo-eks-us-west-2"
  cluster_version                                    = "1.18"
  vpc_id                                             = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_subnets                                    = data.terraform_remote_state.vpc.outputs.public_subnets
  cluster_features                                   = local.cluster_features
  flux_settings                                      = local.flux_settings
  admin_users_arn                                    = ["arn:aws:iam::783633885093:role/maws-admin", "arn:aws:iam::517826968395:role/itsre-admin", "arn:aws:iam::095732026120:role/maws-sumo-poweruser"]
  region                                             = "us-west-2"
  worker_groups                                      = local.worker_groups
  worker_create_cluster_primary_security_group_rules = true
  worker_additional_security_group_ids               = [data.aws_security_group.k8s_nodes.id]
}

data "aws_security_group" "k8s_nodes" {
  name = "nodes.k8s.us-west-2a.sumo.mozit.cloud"
}
