resource "aws_security_group_rule" "ssh-external-to-master-mdc2" {
  type              = "ingress"
  description       = "SSH access to masters from MDC2 VPN"
  security_group_id = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.50.0.0/15"]
}

resource "aws_security_group_rule" "ssh-external-to-node-mdc2" {
  type              = "ingress"
  description       = "SSH access to nodes from MDC2 VPN"
  security_group_id = "${aws_security_group.nodes-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.50.0.0/15"]
}

resource "aws_security_group_rule" "https-external-to-master-mdc2" {
  type              = "ingress"
  description       = "API access from MDC2 VPN"
  security_group_id = "${aws_security_group.masters-k8s-us-west-2b-sumo-mozit-cloud.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.50.0.0/15"]
}
