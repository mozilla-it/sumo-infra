module "redis-test" {
  source                = "./redis"
  redis_name            = "test"
  redis_node_size       = "cache.m5.large"
  redis_param_group     = "default.redis5.0"
  redis_engine_version  = "5.0.5"
  redis_num_nodes       = 3
  redis_failover        = true
  nodes_security_groups = join(",", data.aws_security_groups.kops_sg.ids)
  redis_subnet          = data.terraform_remote_state.vpc.outputs.redis_subnet_group
}

module "mysql-prod" {
  source    = "./rds-multi-az"
  mysql_env = "prod"

  # DBName must begin with a letter and contain only alphanumeric characters
  mysql_db_name                     = "sumo_prod"
  mysql_username                    = "root"
  mysql_password                    = var.mysql_prod_password
  mysql_identifier                  = "sumo"
  mysql_instance_class              = "db.m5.4xlarge"
  mysql_backup_retention_days       = 14
  mysql_security_group_name         = "sumo_rds_sg_prod"
  mysql_storage_gb                  = 250
  mysql_storage_type                = "gp2"
  mysql_allow_major_version_upgrade = true
  mysql_engine_version = {
    mysql = "5.7"
  }

  db_subnet_group = data.terraform_remote_state.vpc.outputs.db_subnet_group
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr        = data.terraform_remote_state.vpc.outputs.cidr_block
  it_vpn_cidr     = var.it_vpn_cidr
  cloud_sql_cidr  = var.cloud_sql_cidr
}
