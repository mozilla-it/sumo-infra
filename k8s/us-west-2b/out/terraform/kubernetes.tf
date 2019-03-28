locals = {
  cluster_name                 = "k8s.us-west-2b.sumo.mozit.cloud"
  master_autoscaling_group_ids = ["${aws_autoscaling_group.master-us-west-2b-1-masters-k8s-us-west-2b-sumo-mozit-cloud.id}", "${aws_autoscaling_group.master-us-west-2b-2-masters-k8s-us-west-2b-sumo-mozit-cloud.id}", "${aws_autoscaling_group.master-us-west-2b-3-masters-k8s-us-west-2b-sumo-mozit-cloud.id}"]
  master_security_group_ids    = ["${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"]
  masters_role_arn             = "${aws_iam_role.masters-k8s-us-west-2b-sumo-mozit-cloud.arn}"
  masters_role_name            = "${aws_iam_role.masters-k8s-us-west-2b-sumo-mozit-cloud.name}"
  node_autoscaling_group_ids   = ["${aws_autoscaling_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"]
  node_security_group_ids      = ["${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"]
  node_subnet_ids              = ["subnet-0017f5099a2316c03"]
  nodes_role_arn               = "${aws_iam_role.nodes-k8s-us-west-2b-sumo-mozit-cloud.arn}"
  nodes_role_name              = "${aws_iam_role.nodes-k8s-us-west-2b-sumo-mozit-cloud.name}"
  region                       = "us-west-2"
  subnet_ids                   = ["subnet-0017f5099a2316c03"]
  subnet_us-west-2b_id         = "subnet-0017f5099a2316c03"
  vpc_id                       = "vpc-0df5c6330b0623c73"
}

output "cluster_name" {
  value = "k8s.us-west-2b.sumo.mozit.cloud"
}

output "master_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.master-us-west-2b-1-masters-k8s-us-west-2b-sumo-mozit-cloud.id}", "${aws_autoscaling_group.master-us-west-2b-2-masters-k8s-us-west-2b-sumo-mozit-cloud.id}", "${aws_autoscaling_group.master-us-west-2b-3-masters-k8s-us-west-2b-sumo-mozit-cloud.id}"]
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-k8s-us-west-2b-sumo-mozit-cloud.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-k8s-us-west-2b-sumo-mozit-cloud.name}"
}

output "node_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"]
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"]
}

output "node_subnet_ids" {
  value = ["subnet-0017f5099a2316c03"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-k8s-us-west-2b-sumo-mozit-cloud.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-k8s-us-west-2b-sumo-mozit-cloud.name}"
}

output "region" {
  value = "us-west-2"
}

output "subnet_ids" {
  value = ["subnet-0017f5099a2316c03"]
}

output "subnet_us-west-2b_id" {
  value = "subnet-0017f5099a2316c03"
}

output "vpc_id" {
  value = "vpc-0df5c6330b0623c73"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_autoscaling_group" "master-us-west-2b-1-masters-k8s-us-west-2b-sumo-mozit-cloud" {
  name                 = "master-us-west-2b-1.masters.k8s.us-west-2b.sumo.mozit.cloud"
  launch_configuration = "${aws_launch_configuration.master-us-west-2b-1-masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["subnet-0017f5099a2316c03"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "k8s.us-west-2b.sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-west-2b-1.masters.k8s.us-west-2b.sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-west-2b-1"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "master-us-west-2b-2-masters-k8s-us-west-2b-sumo-mozit-cloud" {
  name                 = "master-us-west-2b-2.masters.k8s.us-west-2b.sumo.mozit.cloud"
  launch_configuration = "${aws_launch_configuration.master-us-west-2b-2-masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["subnet-0017f5099a2316c03"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "k8s.us-west-2b.sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-west-2b-2.masters.k8s.us-west-2b.sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-west-2b-2"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "master-us-west-2b-3-masters-k8s-us-west-2b-sumo-mozit-cloud" {
  name                 = "master-us-west-2b-3.masters.k8s.us-west-2b.sumo.mozit.cloud"
  launch_configuration = "${aws_launch_configuration.master-us-west-2b-3-masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["subnet-0017f5099a2316c03"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "k8s.us-west-2b.sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-west-2b-3.masters.k8s.us-west-2b.sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-west-2b-3"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "nodes-k8s-us-west-2b-sumo-mozit-cloud" {
  name                 = "nodes.k8s.us-west-2b.sumo.mozit.cloud"
  launch_configuration = "${aws_launch_configuration.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  max_size             = 12
  min_size             = 3
  vpc_zone_identifier  = ["subnet-0017f5099a2316c03"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "k8s.us-west-2b.sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.k8s.us-west-2b.sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_ebs_volume" "1-etcd-events-k8s-us-west-2b-sumo-mozit-cloud" {
  availability_zone = "us-west-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                                       = "k8s.us-west-2b.sumo.mozit.cloud"
    Name                                                    = "1.etcd-events.k8s.us-west-2b.sumo.mozit.cloud"
    "k8s.io/etcd/events"                                    = "1/1,2,3"
    "k8s.io/role/master"                                    = "1"
    "kubernetes.io/cluster/k8s.us-west-2b.sumo.mozit.cloud" = "owned"
  }
}

resource "aws_ebs_volume" "1-etcd-main-k8s-us-west-2b-sumo-mozit-cloud" {
  availability_zone = "us-west-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                                       = "k8s.us-west-2b.sumo.mozit.cloud"
    Name                                                    = "1.etcd-main.k8s.us-west-2b.sumo.mozit.cloud"
    "k8s.io/etcd/main"                                      = "1/1,2,3"
    "k8s.io/role/master"                                    = "1"
    "kubernetes.io/cluster/k8s.us-west-2b.sumo.mozit.cloud" = "owned"
  }
}

resource "aws_ebs_volume" "2-etcd-events-k8s-us-west-2b-sumo-mozit-cloud" {
  availability_zone = "us-west-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                                       = "k8s.us-west-2b.sumo.mozit.cloud"
    Name                                                    = "2.etcd-events.k8s.us-west-2b.sumo.mozit.cloud"
    "k8s.io/etcd/events"                                    = "2/1,2,3"
    "k8s.io/role/master"                                    = "1"
    "kubernetes.io/cluster/k8s.us-west-2b.sumo.mozit.cloud" = "owned"
  }
}

resource "aws_ebs_volume" "2-etcd-main-k8s-us-west-2b-sumo-mozit-cloud" {
  availability_zone = "us-west-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                                       = "k8s.us-west-2b.sumo.mozit.cloud"
    Name                                                    = "2.etcd-main.k8s.us-west-2b.sumo.mozit.cloud"
    "k8s.io/etcd/main"                                      = "2/1,2,3"
    "k8s.io/role/master"                                    = "1"
    "kubernetes.io/cluster/k8s.us-west-2b.sumo.mozit.cloud" = "owned"
  }
}

resource "aws_ebs_volume" "3-etcd-events-k8s-us-west-2b-sumo-mozit-cloud" {
  availability_zone = "us-west-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                                       = "k8s.us-west-2b.sumo.mozit.cloud"
    Name                                                    = "3.etcd-events.k8s.us-west-2b.sumo.mozit.cloud"
    "k8s.io/etcd/events"                                    = "3/1,2,3"
    "k8s.io/role/master"                                    = "1"
    "kubernetes.io/cluster/k8s.us-west-2b.sumo.mozit.cloud" = "owned"
  }
}

resource "aws_ebs_volume" "3-etcd-main-k8s-us-west-2b-sumo-mozit-cloud" {
  availability_zone = "us-west-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                                       = "k8s.us-west-2b.sumo.mozit.cloud"
    Name                                                    = "3.etcd-main.k8s.us-west-2b.sumo.mozit.cloud"
    "k8s.io/etcd/main"                                      = "3/1,2,3"
    "k8s.io/role/master"                                    = "1"
    "kubernetes.io/cluster/k8s.us-west-2b.sumo.mozit.cloud" = "owned"
  }
}

resource "aws_iam_instance_profile" "masters-k8s-us-west-2b-sumo-mozit-cloud" {
  name = "masters.k8s.us-west-2b.sumo.mozit.cloud"
  role = "${aws_iam_role.masters-k8s-us-west-2b-sumo-mozit-cloud.name}"
}

resource "aws_iam_instance_profile" "nodes-k8s-us-west-2b-sumo-mozit-cloud" {
  name = "nodes.k8s.us-west-2b.sumo.mozit.cloud"
  role = "${aws_iam_role.nodes-k8s-us-west-2b-sumo-mozit-cloud.name}"
}

resource "aws_iam_role" "masters-k8s-us-west-2b-sumo-mozit-cloud" {
  name               = "masters.k8s.us-west-2b.sumo.mozit.cloud"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.k8s.us-west-2b.sumo.mozit.cloud_policy")}"
}

resource "aws_iam_role" "nodes-k8s-us-west-2b-sumo-mozit-cloud" {
  name               = "nodes.k8s.us-west-2b.sumo.mozit.cloud"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.k8s.us-west-2b.sumo.mozit.cloud_policy")}"
}

resource "aws_iam_role_policy" "masters-k8s-us-west-2b-sumo-mozit-cloud" {
  name   = "masters.k8s.us-west-2b.sumo.mozit.cloud"
  role   = "${aws_iam_role.masters-k8s-us-west-2b-sumo-mozit-cloud.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.k8s.us-west-2b.sumo.mozit.cloud_policy")}"
}

resource "aws_iam_role_policy" "nodes-k8s-us-west-2b-sumo-mozit-cloud" {
  name   = "nodes.k8s.us-west-2b.sumo.mozit.cloud"
  role   = "${aws_iam_role.nodes-k8s-us-west-2b-sumo-mozit-cloud.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.k8s.us-west-2b.sumo.mozit.cloud_policy")}"
}

resource "aws_key_pair" "kubernetes-k8s-us-west-2b-sumo-mozit-cloud-06875d4fa7222e744e44935bf1a981ab" {
  key_name   = "kubernetes.k8s.us-west-2b.sumo.mozit.cloud-06:87:5d:4f:a7:22:2e:74:4e:44:93:5b:f1:a9:81:ab"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.k8s.us-west-2b.sumo.mozit.cloud-06875d4fa7222e744e44935bf1a981ab_public_key")}"
}

resource "aws_launch_configuration" "master-us-west-2b-1-masters-k8s-us-west-2b-sumo-mozit-cloud" {
  name_prefix                 = "master-us-west-2b-1.masters.k8s.us-west-2b.sumo.mozit.cloud-"
  image_id                    = "ami-0008325f0ded04d04"
  instance_type               = "m4.large"
  key_name                    = "${aws_key_pair.kubernetes-k8s-us-west-2b-sumo-mozit-cloud-06875d4fa7222e744e44935bf1a981ab.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  security_groups             = ["${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-west-2b-1.masters.k8s.us-west-2b.sumo.mozit.cloud_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 250
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "master-us-west-2b-2-masters-k8s-us-west-2b-sumo-mozit-cloud" {
  name_prefix                 = "master-us-west-2b-2.masters.k8s.us-west-2b.sumo.mozit.cloud-"
  image_id                    = "ami-0008325f0ded04d04"
  instance_type               = "m4.large"
  key_name                    = "${aws_key_pair.kubernetes-k8s-us-west-2b-sumo-mozit-cloud-06875d4fa7222e744e44935bf1a981ab.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  security_groups             = ["${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-west-2b-2.masters.k8s.us-west-2b.sumo.mozit.cloud_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 250
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "master-us-west-2b-3-masters-k8s-us-west-2b-sumo-mozit-cloud" {
  name_prefix                 = "master-us-west-2b-3.masters.k8s.us-west-2b.sumo.mozit.cloud-"
  image_id                    = "ami-0008325f0ded04d04"
  instance_type               = "m4.large"
  key_name                    = "${aws_key_pair.kubernetes-k8s-us-west-2b-sumo-mozit-cloud-06875d4fa7222e744e44935bf1a981ab.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  security_groups             = ["${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-west-2b-3.masters.k8s.us-west-2b.sumo.mozit.cloud_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 250
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "nodes-k8s-us-west-2b-sumo-mozit-cloud" {
  name_prefix                 = "nodes.k8s.us-west-2b.sumo.mozit.cloud-"
  image_id                    = "ami-0008325f0ded04d04"
  instance_type               = "m4.xlarge"
  key_name                    = "${aws_key_pair.kubernetes-k8s-us-west-2b-sumo-mozit-cloud-06875d4fa7222e744e44935bf1a981ab.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  security_groups             = ["${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.k8s.us-west-2b.sumo.mozit.cloud_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 250
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_security_group" "masters-k8s-us-west-2b-sumo-mozit-cloud" {
  name        = "masters.k8s.us-west-2b.sumo.mozit.cloud"
  vpc_id      = "vpc-0df5c6330b0623c73"
  description = "Security group for masters"

  tags = {
    KubernetesCluster                                       = "k8s.us-west-2b.sumo.mozit.cloud"
    Name                                                    = "masters.k8s.us-west-2b.sumo.mozit.cloud"
    "kubernetes.io/cluster/k8s.us-west-2b.sumo.mozit.cloud" = "owned"
  }
}

resource "aws_security_group" "nodes-k8s-us-west-2b-sumo-mozit-cloud" {
  name        = "nodes.k8s.us-west-2b.sumo.mozit.cloud"
  vpc_id      = "vpc-0df5c6330b0623c73"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster                                       = "k8s.us-west-2b.sumo.mozit.cloud"
    Name                                                    = "nodes.k8s.us-west-2b.sumo.mozit.cloud"
    "kubernetes.io/cluster/k8s.us-west-2b.sumo.mozit.cloud" = "owned"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "https-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["97.120.19.209/32"]
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-protocol-ipip" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "4"
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4001" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port                = 2382
  to_port                  = 4001
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-97-120-19-209--32" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["97.120.19.209/32"]
}

resource "aws_security_group_rule" "ssh-external-to-node-97-120-19-209--32" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["97.120.19.209/32"]
}

terraform = {
  required_version = ">= 0.9.3"
}
