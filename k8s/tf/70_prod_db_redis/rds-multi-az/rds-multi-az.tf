resource "aws_kms_key" "key" {
  description = "KMS key for prod RDS"
  key_usage   = "ENCRYPT_DECRYPT"
  is_enabled  = true
}

resource "aws_db_instance" "sumo_rds" {
  allocated_storage            = var.mysql_storage_gb
  allow_major_version_upgrade  = var.mysql_allow_major_version_upgrade
  auto_minor_version_upgrade   = var.mysql_auto_minor_version_upgrade
  backup_retention_period      = var.mysql_backup_retention_days
  backup_window                = var.mysql_backup_window
  db_subnet_group_name         = var.db_subnet_group
  depends_on                   = [aws_security_group.sumo_rds_sg]
  engine                       = var.mysql_engine
  engine_version               = var.mysql_engine_version[var.mysql_engine]
  identifier                   = var.mysql_identifier
  instance_class               = var.mysql_instance_class
  maintenance_window           = var.mysql_maintenance_window
  multi_az                     = true
  name                         = var.mysql_db_name
  password                     = var.mysql_password
  publicly_accessible          = true
  storage_encrypted            = var.mysql_storage_encrypted
  storage_type                 = var.mysql_storage_type
  username                     = var.mysql_username
  vpc_security_group_ids       = [aws_security_group.sumo_rds_sg.id]
  final_snapshot_identifier    = "sumo-final-db-snapshot"
  kms_key_id                   = aws_kms_key.key.arn
  deletion_protection          = true
  performance_insights_enabled = true

  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery",
  ]

  tags = {
    "Stack"       = "SUMO-${var.mysql_env}"
    "Terraform"   = "true"
    "Project"     = "sumo"
    "Region"      = "us-west-2"
    "Environment" = "prod"
  }
}

resource "aws_security_group" "sumo_rds_sg" {
  name        = var.mysql_security_group_name
  description = "Allow all inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.mysql_port
    to_port     = var.mysql_port
    protocol    = "TCP"
    cidr_blocks = [var.vpc_cidr, var.it_vpn_cidr, var.cloud_sql_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"        = var.mysql_security_group_name
    "Terraform"   = "true"
    "Project"     = "sumo"
    "Region"      = "us-west-2"
    "Environment" = "prod"
  }
}
