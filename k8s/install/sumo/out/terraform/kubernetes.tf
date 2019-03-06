locals = {
  cluster_name                 = "sumo.mozit.cloud"
  master_autoscaling_group_ids = ["${aws_autoscaling_group.master-us-west-2a-masters-sumo-mozit-cloud.id}"]
  master_security_group_ids    = ["${aws_security_group.masters-sumo-mozit-cloud.id}"]
  masters_role_arn             = "${aws_iam_role.masters-sumo-mozit-cloud.arn}"
  masters_role_name            = "${aws_iam_role.masters-sumo-mozit-cloud.name}"
  node_autoscaling_group_ids   = ["${aws_autoscaling_group.nodes-sumo-mozit-cloud.id}"]
  node_security_group_ids      = ["${aws_security_group.nodes-sumo-mozit-cloud.id}"]
  node_subnet_ids              = ["${aws_subnet.us-west-2a-sumo-mozit-cloud.id}"]
  nodes_role_arn               = "${aws_iam_role.nodes-sumo-mozit-cloud.arn}"
  nodes_role_name              = "${aws_iam_role.nodes-sumo-mozit-cloud.name}"
  region                       = "us-west-2"
  route_table_public_id        = "${aws_route_table.sumo-mozit-cloud.id}"
  subnet_us-west-2a_id         = "${aws_subnet.us-west-2a-sumo-mozit-cloud.id}"
  vpc_id                       = "vpc-08c9635ff751b8e53"
}

output "cluster_name" {
  value = "sumo.mozit.cloud"
}

output "master_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.master-us-west-2a-masters-sumo-mozit-cloud.id}"]
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-sumo-mozit-cloud.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-sumo-mozit-cloud.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-sumo-mozit-cloud.name}"
}

output "node_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.nodes-sumo-mozit-cloud.id}"]
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-sumo-mozit-cloud.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.us-west-2a-sumo-mozit-cloud.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-sumo-mozit-cloud.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-sumo-mozit-cloud.name}"
}

output "region" {
  value = "us-west-2"
}

output "route_table_public_id" {
  value = "${aws_route_table.sumo-mozit-cloud.id}"
}

output "subnet_us-west-2a_id" {
  value = "${aws_subnet.us-west-2a-sumo-mozit-cloud.id}"
}

output "vpc_id" {
  value = "vpc-08c9635ff751b8e53"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_autoscaling_group" "master-us-west-2a-masters-sumo-mozit-cloud" {
  name                 = "master-us-west-2a.masters.sumo.mozit.cloud"
  launch_configuration = "${aws_launch_configuration.master-us-west-2a-masters-sumo-mozit-cloud.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.us-west-2a-sumo-mozit-cloud.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-west-2a.masters.sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-west-2a"
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

resource "aws_autoscaling_group" "nodes-sumo-mozit-cloud" {
  name                 = "nodes.sumo.mozit.cloud"
  launch_configuration = "${aws_launch_configuration.nodes-sumo-mozit-cloud.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.us-west-2a-sumo-mozit-cloud.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "sumo.mozit.cloud"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.sumo.mozit.cloud"
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

resource "aws_ebs_volume" "a-etcd-events-sumo-mozit-cloud" {
  availability_zone = "us-west-2a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                        = "sumo.mozit.cloud"
    Name                                     = "a.etcd-events.sumo.mozit.cloud"
    "k8s.io/etcd/events"                     = "a/a"
    "k8s.io/role/master"                     = "1"
    "kubernetes.io/cluster/sumo.mozit.cloud" = "owned"
  }
}

resource "aws_ebs_volume" "a-etcd-main-sumo-mozit-cloud" {
  availability_zone = "us-west-2a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                        = "sumo.mozit.cloud"
    Name                                     = "a.etcd-main.sumo.mozit.cloud"
    "k8s.io/etcd/main"                       = "a/a"
    "k8s.io/role/master"                     = "1"
    "kubernetes.io/cluster/sumo.mozit.cloud" = "owned"
  }
}

resource "aws_iam_instance_profile" "masters-sumo-mozit-cloud" {
  name = "masters.sumo.mozit.cloud"
  role = "${aws_iam_role.masters-sumo-mozit-cloud.name}"
}

resource "aws_iam_instance_profile" "nodes-sumo-mozit-cloud" {
  name = "nodes.sumo.mozit.cloud"
  role = "${aws_iam_role.nodes-sumo-mozit-cloud.name}"
}

resource "aws_iam_role" "masters-sumo-mozit-cloud" {
  name               = "masters.sumo.mozit.cloud"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.sumo.mozit.cloud_policy")}"
}

resource "aws_iam_role" "nodes-sumo-mozit-cloud" {
  name               = "nodes.sumo.mozit.cloud"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.sumo.mozit.cloud_policy")}"
}

resource "aws_iam_role_policy" "masters-sumo-mozit-cloud" {
  name   = "masters.sumo.mozit.cloud"
  role   = "${aws_iam_role.masters-sumo-mozit-cloud.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.sumo.mozit.cloud_policy")}"
}

resource "aws_iam_role_policy" "nodes-sumo-mozit-cloud" {
  name   = "nodes.sumo.mozit.cloud"
  role   = "${aws_iam_role.nodes-sumo-mozit-cloud.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.sumo.mozit.cloud_policy")}"
}

resource "aws_key_pair" "kubernetes-sumo-mozit-cloud-3487caebf6e06151c19ef85d3e2bba12" {
  key_name   = "kubernetes.sumo.mozit.cloud-34:87:ca:eb:f6:e0:61:51:c1:9e:f8:5d:3e:2b:ba:12"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.sumo.mozit.cloud-3487caebf6e06151c19ef85d3e2bba12_public_key")}"
}

resource "aws_launch_configuration" "master-us-west-2a-masters-sumo-mozit-cloud" {
  name_prefix                 = "master-us-west-2a.masters.sumo.mozit.cloud-"
  image_id                    = "ami-0008325f0ded04d04"
  instance_type               = "m4.large"
  key_name                    = "${aws_key_pair.kubernetes-sumo-mozit-cloud-3487caebf6e06151c19ef85d3e2bba12.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-sumo-mozit-cloud.id}"
  security_groups             = ["${aws_security_group.masters-sumo-mozit-cloud.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-west-2a.masters.sumo.mozit.cloud_user_data")}"

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

resource "aws_launch_configuration" "nodes-sumo-mozit-cloud" {
  name_prefix                 = "nodes.sumo.mozit.cloud-"
  image_id                    = "ami-0008325f0ded04d04"
  instance_type               = "m4.xlarge"
  key_name                    = "${aws_key_pair.kubernetes-sumo-mozit-cloud-3487caebf6e06151c19ef85d3e2bba12.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-sumo-mozit-cloud.id}"
  security_groups             = ["${aws_security_group.nodes-sumo-mozit-cloud.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.sumo.mozit.cloud_user_data")}"

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

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.sumo-mozit-cloud.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "igw-021bcc62f1fc7b49b"
}

resource "aws_route_table" "sumo-mozit-cloud" {
  vpc_id = "vpc-08c9635ff751b8e53"

  tags = {
    KubernetesCluster                        = "sumo.mozit.cloud"
    Name                                     = "sumo.mozit.cloud"
    "kubernetes.io/cluster/sumo.mozit.cloud" = "owned"
    "kubernetes.io/kops/role"                = "public"
  }
}

resource "aws_route_table_association" "us-west-2a-sumo-mozit-cloud" {
  subnet_id      = "${aws_subnet.us-west-2a-sumo-mozit-cloud.id}"
  route_table_id = "${aws_route_table.sumo-mozit-cloud.id}"
}

resource "aws_security_group" "masters-sumo-mozit-cloud" {
  name        = "masters.sumo.mozit.cloud"
  vpc_id      = "vpc-08c9635ff751b8e53"
  description = "Security group for masters"

  tags = {
    KubernetesCluster                        = "sumo.mozit.cloud"
    Name                                     = "masters.sumo.mozit.cloud"
    "kubernetes.io/cluster/sumo.mozit.cloud" = "owned"
  }
}

resource "aws_security_group" "nodes-sumo-mozit-cloud" {
  name        = "nodes.sumo.mozit.cloud"
  vpc_id      = "vpc-08c9635ff751b8e53"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster                        = "sumo.mozit.cloud"
    Name                                     = "nodes.sumo.mozit.cloud"
    "kubernetes.io/cluster/sumo.mozit.cloud" = "owned"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-sumo-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "https-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-sumo-mozit-cloud.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-protocol-ipip" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-sumo-mozit-cloud.id}"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "4"
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-sumo-mozit-cloud.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4001" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-sumo-mozit-cloud.id}"
  from_port                = 2382
  to_port                  = 4001
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-sumo-mozit-cloud.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  source_security_group_id = "${aws_security_group.nodes-sumo-mozit-cloud.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-64-53-133-59--32" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-sumo-mozit-cloud.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["64.53.133.59/32"]
}

resource "aws_security_group_rule" "ssh-external-to-node-64-53-133-59--32" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-sumo-mozit-cloud.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["64.53.133.59/32"]
}

resource "aws_subnet" "us-west-2a-sumo-mozit-cloud" {
  vpc_id            = "vpc-08c9635ff751b8e53"
  cidr_block        = "10.0.32.0/19"
  availability_zone = "us-west-2a"

  tags = {
    KubernetesCluster                        = "sumo.mozit.cloud"
    Name                                     = "us-west-2a.sumo.mozit.cloud"
    SubnetType                               = "Public"
    "kubernetes.io/cluster/sumo.mozit.cloud" = "owned"
    "kubernetes.io/role/elb"                 = "1"
  }
}

terraform = {
  required_version = ">= 0.9.3"
}
