resource "aws_key_pair" "sumo" {
  lifecycle {
    create_before_destroy = true
  }

  key_name   = "sumo"
  public_key = "${var.ssh_pubkey}"
}

# Create a new load balancer
resource "aws_lb" "ci" {
  name               = "${var.project}-${var.service}-lb"
  subnets            = ["${data.aws_subnet_ids.subnet_id.ids}"]
  security_groups    = ["${aws_security_group.lb.id}"]
  load_balancer_type = "application"
  internal           = true

  tags = "${var.base_tags}"
}

resource "aws_lb_target_group" "ci-http" {
  name     = "${var.project}-${var.service}-tg-http"
  vpc_id   = "${data.terraform_remote_state.sumo-prod-us-west-2.vpc_id}"
  port     = 80
  protocol = "HTTP"

  health_check {
    interval            = 30
    path                = "/"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,401"
  }

  tags = "${var.base_tags}"
}

resource "aws_lb_listener" "ci-http" {
  load_balancer_arn = "${aws_lb.ci.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "ci-https" {
  load_balancer_arn = "${aws_lb.ci.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.ci.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.ci-http.arn}"
  }
}

resource "aws_security_group" "lb" {
  name        = "${var.project}-${var.service}-lb-sg"
  description = "Allow inbound traffic from LB to CI"

  vpc_id = "${data.terraform_remote_state.sumo-prod-us-west-2.vpc_id}"

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

  tags = "${var.base_tags}"
}

resource "aws_security_group" "ci" {
  name        = "${var.project}-${var.service}-sg"
  description = "Allow inbound traffic to CI"

  vpc_id = "${data.terraform_remote_state.sumo-prod-us-west-2.vpc_id}"

  tags = "${merge(map("Name", "${var.project}-${var.service}-sg"), var.base_tags)}"
}

resource "aws_security_group_rule" "ci-ssh" {
  type              = "ingress"
  description       = "SSH via VPN"
  security_group_id = "${aws_security_group.ci.id}"
  from_port         = "22"
  to_port           = "22"
  protocol          = "TCP"
  cidr_blocks       = ["${var.mdc1_cidr}", "${var.mdc2_cidr}"]
}

resource "aws_security_group_rule" "ci-http" {
  type                     = "ingress"
  description              = "HTTP via VPN"
  security_group_id        = "${aws_security_group.ci.id}"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.lb.id}"
}

resource "aws_security_group_rule" "ci-https" {
  type                     = "ingress"
  description              = "HTTPS via VPN"
  security_group_id        = "${aws_security_group.ci.id}"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.lb.id}"
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
  name                      = "${var.project}-${var.service} - ${aws_launch_configuration.ci.name}"
  target_group_arns         = ["${aws_lb_target_group.ci-http.arn}"]
  min_elb_capacity          = 1
  wait_for_capacity_timeout = "0"

  lifecycle {
    create_before_destroy = true
  }

  max_size                  = "1"
  min_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 300

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

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.tpl")}"

  vars = {
    backup_dir          = "${var.backup_dir}"
    backup_bucket       = "${aws_s3_bucket.backup.id}"
    nginx_htpasswd      = "${var.nginx_htpasswd}"
    jenkins_backup_dms  = "${var.jenkins_backup_dms}"
    papertrail_host     = "${var.papertrail_host}"
    papertrail_port     = "${var.papertrail_port}"
    slack_token         = "${var.slack_token}"
    parameter_root_name = "${var.parameter_root_name}"
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

resource "aws_route53_record" "ci" {
  zone_id = "${var.route53_zone}"
  name    = "ci.sumo.mozit.cloud"
  type    = "CNAME"
  ttl     = 60
  records = ["${aws_lb.ci.dns_name}"]
}

resource "random_id" "rand-var" {
  keepers = {
    backup_bucket = "${var.backup_bucket}"
  }

  byte_length = 8
}

resource "aws_s3_bucket" "backup" {
  bucket = "${var.backup_bucket}-${random_id.rand-var.hex}"
  acl    = "private"

  tags = "${merge(
            map("Name", "${var.project}-${var.service}-s3backup"),
            map("Purpose", "Backup bucket for CI system"),
            var.base_tags
          )}"
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

resource "aws_iam_role_policy" "ci-backup" {
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

resource "aws_iam_role_policy" "static-assets" {
  name = "${var.project}-${var.service}-static-assets"
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
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${var.static_s3_prefix}",
        "arn:aws:s3:::${var.static_s3_prefix}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = "${aws_iam_role.ci.id}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

locals {
  # Normalise the parameter name, and remove any duplicate slashes
  parameter_root_name = "${join("/",compact(split("/", var.parameter_root_name)))}"
}

resource "aws_iam_role_policy" "ci-ssm" {
  name = "${var.project}-${var.service}-ssm-parameter"
  role = "${aws_iam_role.ci.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {

      "Effect": "Allow",
      "Action": [
         "ssm:GetParameters",
         "ssm:GetParameter",
         "ssm:GetParameterHistory",
         "ssm:GetParametersByPath"
      ],
      "Resource": [
        "arn:aws:ssm:${var.region}:${data.aws_caller_identity.id.account_id}:parameter/${local.parameter_root_name}*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": [
        "${aws_kms_key.ci-ssm.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_kms_key" "ci-ssm" {
  description             = "${var.project}-${var.service}-ssm-parameter"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = "${var.base_tags}"
}

resource "aws_ssm_parameter" "ci" {
  name        = "/${local.parameter_root_name}"
  description = "SSH deploy key for l10n locale repository"
  type        = "SecureString"
  value       = "${var.gh_deploy_key}"
  key_id      = "${aws_kms_key.ci-ssm.key_id}"

  tags = "${var.base_tags}"
}
