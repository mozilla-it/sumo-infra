resource "aws_security_group" "sumo_rds_sg" {
  name        = "${var.mysql_security_group_name}"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.mysql_port}"
    to_port     = "${var.mysql_port}"
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.mysql_security_group_name}"
  }
}

resource "aws_db_instance" "sumo_rds" {
  allocated_storage           = "${var.mysql_storage_gb}"
  allow_major_version_upgrade = "${var.mysql_allow_major_version_upgrade}"
  auto_minor_version_upgrade  = "${var.mysql_auto_minor_version_upgrade}"
  backup_retention_period     = "${var.mysql_backup_retention_days}"
  backup_window               = "${var.mysql_backup_window}"
  db_subnet_group_name        = "${var.db_subnet_group_name}"
#  mysql_security_group_name   = "${var.mysql_security_group_name}"

  depends_on             = ["aws_security_group.sumo_rds_sg"]
  engine                 = "${var.mysql_engine}"
  engine_version         = "${lookup(var.mysql_engine_version, var.mysql_engine)}"
  identifier             = "${var.mysql_identifier}"
  instance_class         = "${var.mysql_instance_class}"
  maintenance_window     = "${var.mysql_maintenance_window}"
  multi_az               = true
  name                   = "${var.mysql_db_name}"
  password               = "${var.mysql_password}"
  publicly_accessible    = false
  storage_encrypted      = "${var.mysql_storage_encrypted}"
  storage_type           = "${var.mysql_storage_type}"
  username               = "${var.mysql_username}"
  vpc_security_group_ids = ["${aws_security_group.sumo_rds_sg.id}"]
  skip_final_snapshot    = true

  tags {
    "Stack" = "SUMO-${var.mysql_env}"
  }
}
