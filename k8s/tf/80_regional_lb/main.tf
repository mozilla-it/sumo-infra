resource "aws_security_group" "lb" {
  name        = "${var.project}-global-lb-sg"
  description = "Allow inbound traffic from LB to nodes"

  vpc_id = data.terraform_remote_state.sumo-prod-us-west-2.outputs.vpc_id

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

  tags = var.base_tags
}

resource "aws_security_group" "lb-ib" {
  name        = "${var.base_tags["service"]}-internet-sg"
  description = "Allow public Internet to access LB ports"
  vpc_id      = data.terraform_remote_state.sumo-prod-us-west-2.outputs.vpc_id

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
  source_security_group_id = aws_security_group.lb.id
  security_group_id        = data.aws_security_group.nodes-a.id
}

resource "aws_security_group_rule" "nodes-b" {
  description              = "Allow LB to NodePort on us-west-2b nodes"
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id
  security_group_id        = data.aws_security_group.nodes-b.id
}
