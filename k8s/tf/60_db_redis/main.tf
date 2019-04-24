#########################################
# Redis
#########################################

module "redis-shared" {
  source                = "redis"
  redis_name            = "shared"
  redis_node_size       = "cache.m3.large"
  redis_num_nodes       = 3
  subnets               = "${join(",", data.aws_subnet_ids.elasticache.ids)}"
  nodes_security_groups = "${join(", ", data.aws_security_groups.kops_sg.ids)}"
}

#########################################
# MySQL
#########################################
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
  mysql_storage_gb            = 250
  mysql_storage_type          = "gp2"

  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_cidr = "${data.aws_subnet.database.*.cidr_block[0]}"
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
    vpc_cidr = "${join(", ", data.aws_subnet.database.*.cidr_block)}"
}
*/

module "mysql-prod" {
  source = "rds-multi-az"

  # DBName must begin with a letter and contain only alphanumeric characters
  mysql_env                   = "prod"
  mysql_db_name               = "sumo_prod"
  mysql_username              = "root"
  mysql_password              = "${var.mysql_prod_password}"
  mysql_identifier            = "sumo"
  mysql_instance_class        = "db.m4.2xlarge"
  mysql_backup_retention_days = 7
  mysql_security_group_name   = "sumo_rds_sg_prod"
  mysql_storage_gb            = 250
  mysql_storage_type          = "gp2"
  subnets                     = "${join(",", data.aws_subnet_ids.database.ids)}"
  vpc_id                      = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_cidr                    = "${data.aws_subnet.database.*.cidr_block[0]}"
}
