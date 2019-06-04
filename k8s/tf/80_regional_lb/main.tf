resource "aws_security_group" "lb" {
  name        = "${var.project}-global-lb-sg"
  description = "Allow inbound traffic from LB to nodes"

  vpc_id = "${data.terraform_remote_state.sumo-prod-us-west-2.vpc_id}"

  ingress {
    from_port   = 30000
    to_port     = 32767
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

resource "aws_security_group" "lb-ib" {
  name        = "${var.base_tags["service"]}-internet-sg"
  description = "Allow public Internet to access LB ports"
  vpc_id      = "${data.terraform_remote_state.sumo-prod-us-west-2.vpc_id}"

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
}

resource "aws_security_group_rule" "nodes-a" {
  description              = "Allow LB to NodePort on us-west-2a nodes"
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.lb.id}"
  security_group_id        = "${data.aws_security_group.nodes-a.id}"
}

resource "aws_security_group_rule" "nodes-b" {
  description              = "Allow LB to NodePort on us-west-2b nodes"
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.lb.id}"
  security_group_id        = "${data.aws_security_group.nodes-b.id}"
}

resource "aws_elb" "prod" {
  name            = "${var.base_tags["service"]}"
  subnets         = "${var.prod_public_subnets}"
  security_groups = ["${aws_security_group.lb.id}", "${aws_security_group.lb-ib.id}"]

  listener {
    instance_port     = "30443"
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = "30443"
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.ssl_cert_prod}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    timeout             = 5
    target              = "HTTP:30443/healthz/"
    interval            = 10
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = "${var.base_tags}"
}

resource "aws_autoscaling_attachment" "prod-a" {
  autoscaling_group_name = "${data.aws_autoscaling_groups.group-a.names[0]}"
  elb                    = "${aws_elb.prod.id}"
}

resource "aws_autoscaling_attachment" "prod-b" {
  autoscaling_group_name = "${data.aws_autoscaling_groups.group-b.names[0]}"
  elb                    = "${aws_elb.prod.id}"
}

resource "aws_route53_record" "lb" {
  zone_id = "${var.sumo_zone_id}"
  name    = "${var.lb_hostname}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_elb.prod.dns_name}"]
}
