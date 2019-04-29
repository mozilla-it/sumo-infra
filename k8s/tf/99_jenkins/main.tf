resource "aws_key_pair" "sumo" {
  lifecycle {
    create_before_destroy = true
  }

  key_name   = "sumo"
  public_key = "${var.ssh_pubkey}"
}

resource "aws_security_group" "ci" {
  name        = "${var.project}-${var.service}-sg"
  description = "Allow inbound traffic to CI"

  vpc_id = "${data.terraform_remote_state.sumo-prod-us-west-2.vpc_id}"

  tags = {
    Name      = "${var.project}-${var.service}-sg"
    Service   = "${var.project}-${var.service}"
    Region    = "${var.region}"
    Terraform = "true"
  }
}

resource "aws_security_group_rule" "ci-ssh" {
  type              = "ingress"
  description       = "SSH via VPN"
  security_group_id = "${aws_security_group.ci.id}"
  from_port         = "22"
  to_port           = "22"
  protocol          = "TCP"
  cidr_blocks       = ["${var.mdc_cidr}"]
}

resource "aws_security_group_rule" "ci-http" {
  type              = "ingress"
  description       = "HTTP via VPN"
  security_group_id = "${aws_security_group.ci.id}"
  from_port         = "80"
  to_port           = "80"
  protocol          = "TCP"
  cidr_blocks       = ["${var.mdc_cidr}"]
}

resource "aws_security_group_rule" "ci-https" {
  type              = "ingress"
  description       = "HTTPS via VPN"
  security_group_id = "${aws_security_group.ci.id}"
  from_port         = "443"
  to_port           = "443"
  protocol          = "TCP"
  cidr_blocks       = ["${var.mdc_cidr}"]
}

resource "aws_security_group_rule" "ci-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.ci.id}"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_autoscaling_group" "ci" {
  vpc_zone_identifier = ["${data.aws_subnet_ids.subnet_id.ids}"]

  # This is on purpose, when the LC changes, will force creation of a new ASG
  name = "${var.project}-${var.service} - ${aws_launch_configuration.ci.name}"

  lifecycle {
    create_before_destroy = true
  }

  max_size                  = "1"
  min_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 1800

  # Less than ideal but the initial sync takes such a long time
  health_check_type    = "EC2"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.ci.name}"

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.service}-${var.region}-asg-instance"
    propagate_at_launch = true
  }

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
    backup_dir         = "${var.backup_dir}"
    backup_bucket      = "${aws_s3_bucket.backup.id}"
    nginx_htpasswd     = "${var.nginx_htpasswd}"
    jenkins_backup_dms = "${var.jenkins_backup_dms}"
    papertrail_host    = "${var.papertrail_host}"
    papertrail_port    = "${var.papertrail_port}"
  }
}

resource "aws_launch_configuration" "ci" {
  name_prefix = "${var.project}-${var.service}-"

  image_id = "${data.aws_ami.ubuntu.id}"

  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.sumo.key_name}"
  associate_public_ip_address = false
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
