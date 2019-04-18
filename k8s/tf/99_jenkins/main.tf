provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/ci"
    region = "us-west-2"
  }
}

resource "aws_key_pair" "sumo" {
  lifecycle {
    create_before_destroy = true
  }

  key_name   = "sumo"
  public_key = "${var.ssh_pubkey}"
}

# Create a new load balancer

resource "aws_eip" "eip" {
  count = "${length(data.aws_subnet_ids.subnet_id.ids)}"
  vpc   = true

  tags = {
    Name        = "${var.service}-nlb-eip"
    Service     = "${var.project}-${var.service}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

locals {
  listeners = [
    {
      port        = "80"
      target_port = "80"
    },
    {
      port        = "443"
      target_port = "443"
    },
  ]
}

resource "aws_lb" "balancer" {
  name               = "${var.project}-${var.service}-nlb"
  load_balancer_type = "network"
  internal           = false

  enable_cross_zone_load_balancing = true

  # Have to hardcode :(

  subnet_mapping {
    subnet_id     = "${element(data.aws_subnet_ids.subnet_id.ids, 0)}"
    allocation_id = "${aws_eip.eip.0.id}"
  }

  subnet_mapping {
    subnet_id     = "${element(data.aws_subnet_ids.subnet_id.ids, 1)}"
    allocation_id = "${aws_eip.eip.1.id}"
  }

  subnet_mapping {
    subnet_id     = "${element(data.aws_subnet_ids.subnet_id.ids, 2)}"
    allocation_id = "${aws_eip.eip.2.id}"
  }

  tags = {
    Name        = "${var.service}-nlb"
    Service     = "${var.project}-${var.service}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_lb_target_group" "balancer_target_group-http" {
  name     = "http-80"
  port     = "80"
  protocol = "TCP"
  vpc_id   = "${data.terraform_remote_state.kubernetes-us-west-2.vpc_id}"
}

resource "aws_lb_target_group" "balancer_target_group-https" {
  name     = "https-443"
  port     = "443"
  protocol = "TCP"
  vpc_id   = "${data.terraform_remote_state.kubernetes-us-west-2.vpc_id}"
}

resource "aws_lb_listener" "balancer_listener-http" {
  load_balancer_arn = "${aws_lb.balancer.id}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.balancer_target_group-http.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "balancer_listener-https" {
  load_balancer_arn = "${aws_lb.balancer.id}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.balancer_target_group-https.id}"
    type             = "forward"
  }
}

resource "aws_security_group" "elb" {
  name        = "${var.project}-${var.service}-elb-sg"
  description = "Allow inbound traffic from ELB to CI"

  vpc_id = "${data.terraform_remote_state.kubernetes-us-west-2.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service}-elb-sg"
    Service     = "${var.project}-${var.service}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_security_group" "ci" {
  name        = "${var.project}-${var.service}-sg"
  description = "Allow inbound traffic to CI from ELB"

  vpc_id = "${data.terraform_remote_state.kubernetes-us-west-2.vpc_id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.elb.id}",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.elb.id}",
    ]
  }

  ingress {
    description       = "Allow SSH access from whitelist"
    from_port         = "22"
    to_port           = "22"
    protocol          = "TCP"
    cidr_blocks       = "${var.ip_whitelist}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service}-sg"
    Service     = "${var.project}-${var.service}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_autoscaling_group" "ci" {
  vpc_zone_identifier = ["${data.aws_subnet_ids.subnet_id.ids}"]

  # This is on purpose, when the LC changes, will force creation of a new ASG
  name = "${var.project}-${var.service} - ${aws_launch_configuration.ci.name}"

  load_balancers = ["${aws_lb.balancer.name}"]

  lifecycle {
    create_before_destroy = true
  }

  max_size                  = "1"
  min_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 1800
  # Less than ideal but the initial sync takes such a long time
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.ci.name}"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

}

data template_file "user_data" {
  template = "${file("${path.module}/templates/user_data.tpl")}"

  vars = {
    backup_dir           = "${var.backup_dir}"
    backup_bucket        = "${aws_s3_bucket.backup.id}"
    nginx_htpasswd       = "${var.nginx_htpasswd}"
    jenkins_backup_dms   = "${var.jenkins_backup_dms}"
    papertrail_host      = "${var.papertrail_host}"
    papertrail_port      = "${var.papertrail_port}"
  }
}

resource "aws_launch_configuration" "ci" {
  name_prefix = "${var.project}-${var.service}-"

  image_id = "${data.aws_ami.ubuntu.id}"

  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.sumo.key_name}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  security_groups = [
    "${aws_security_group.ci.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.ci.name}"

  enable_monitoring = false

  root_block_device = {
    volume_size           = "250"
    volume_type           = "gp2"
    delete_on_termination = false
  }
}

resource "aws_autoscaling_attachment" "http" {
  autoscaling_group_name = "${aws_autoscaling_group.ci.id}"
  alb_target_group_arn   = "${aws_lb_target_group.balancer_target_group-http.arn}"
}

resource "aws_autoscaling_attachment" "https" {
  autoscaling_group_name = "${aws_autoscaling_group.ci.id}"
  alb_target_group_arn   = "${aws_lb_target_group.balancer_target_group-https.arn}"
}

resource "random_id" "rand-var" {
  keepers = {
    backup_bucket = "${var.backup_bucket}"
  }

  byte_length = 8
}

resource aws_s3_bucket "backup" {
  bucket = "${var.backup_bucket}-${random_id.rand-var.hex}"
  acl    = "private"

  tags {
    Name      = "${var.service}-s3backup"
    Service   = "${var.project}-${var.service}"
    Region    = "${var.region}"
    Purpose   = "Backup bucket for CI system"
    Terraform = "true"
  }
}

resource "aws_iam_instance_profile" "ci" {
  name = "${var.project}-${var.service}-${var.region}"
  role = "${aws_iam_role.ci.name}"
}

resource "aws_iam_role" "ci" {
  name = "${var.project}-${var.service}-${var.region}"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource aws_iam_role_policy "ci-backup" {
  name = "${var.project}-${var.service}-backups-${var.region}"
  role = "${aws_iam_role.ci.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListAllBuckets",
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ListBucket",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.backup.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.backup.arn}",
        "${aws_s3_bucket.backup.arn}/*"
      ]
    }
  ]
}
EOF
}

