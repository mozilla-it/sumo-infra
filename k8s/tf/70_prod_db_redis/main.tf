module "redis-shared" {
  source                = "redis"
  redis_name            = "shared"
  redis_node_size       = "cache.m3.large"
  redis_num_nodes       = 3
  nodes_security_groups = "${join(",", data.aws_security_groups.kops_sg.ids)}"
  redis_subnet          = "${data.terraform_remote_state.vpc.redis_subnet_group}"
}

module "mysql-prod" {
  source    = "rds-multi-az"
  mysql_env = "prod"

  # DBName must begin with a letter and contain only alphanumeric characters
  mysql_db_name               = "sumo_prod"
  mysql_username              = "root"
  mysql_password              = "${var.mysql_prod_password}"
  mysql_identifier            = "sumo"
  mysql_instance_class        = "db.m5.4xlarge"
  mysql_backup_retention_days = 7
  mysql_security_group_name   = "sumo_rds_sg_prod"
  mysql_storage_gb            = 250
  mysql_storage_type          = "gp2"

  db_subnet_group = "${data.terraform_remote_state.vpc.db_subnet_group}"
  vpc_id          = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_cidr        = "${data.terraform_remote_state.vpc.cidr_block}"
  it_vpn_cidr     = "${var.it_vpn_cidr}"
}
