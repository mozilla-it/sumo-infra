module "mysql-dev" {
  source    = "rds"
  mysql_env = "dev"

  # DBName must begin with a letter and contain only alphanumeric characters
  mysql_db_name               = "sumo_dev"
  mysql_username              = "root"
  mysql_password              = "${var.mysql_dev_password}"
  mysql_identifier            = "sumo-dev"
  mysql_instance_class        = "db.t2.small"
  mysql_backup_retention_days = 0
  mysql_security_group_name   = "sumo_rds_sg_dev"
  db_subnet_group_name        = "${data.terraform_remote_state.vpc.db_subnet_group}"
  mysql_storage_gb            = 250
  mysql_storage_type          = "gp2"
  vpc_id                      = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_cidr                    = "${data.terraform_remote_state.vpc.cidr_block}"
}

/*
module "mysql-stage" {
    source = "rds"
    mysql_env     = "stage"
    # DBName must begin with a letter and contain only alphanumeric characters
    mysql_db_name = "sumo_stage"
    mysql_username = "root"
    mysql_password = "${var.mysql_stage_password}"
    mysql_identifier = "sumo-stage"
    mysql_instance_class = "db.t2.small"
    mysql_backup_retention_days = 0
    mysql_security_group_name = "sumo_rds_sg_stage"
    mysql_storage_gb = 250
    mysql_storage_type = "gp2"
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
    vpc_cidr                    = "${data.terraform_remote_state.vpc.cidr_block}"
}
*/

