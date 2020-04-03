module "redis-shared" {
  source                = "./redis"
  redis_name            = "dev"
  redis_node_size       = "cache.m3.large"
  redis_num_nodes       = 3
  subnets               = join(",", data.aws_subnet_ids.elasticache.ids)
  nodes_security_groups = join(",", data.aws_security_groups.kops_sg.ids)
  redis_subnet          = data.terraform_remote_state.vpc.outputs.redis_subnet_group
}

module "redis-test" {
  source                = "./redis"
  redis_name            = "test"
  redis_node_size       = "cache.m5.large"
  redis_param_group     = "default.redis5.0"
  redis_engine_version  = "5.0.5"
  redis_num_nodes       = 3
  subnets               = join(",", data.aws_subnet_ids.elasticache.ids)
  nodes_security_groups = join(",", data.aws_security_groups.kops_sg.ids)
  redis_subnet          = data.terraform_remote_state.vpc.outputs.redis_subnet_group
}

module "mysql-dev" {
  source    = "./rds"
  mysql_env = "dev"

  # DBName must begin with a letter and contain only alphanumeric characters
  mysql_db_name               = "sumo_dev"
  mysql_username              = "root"
  mysql_password              = var.mysql_dev_password
  mysql_identifier            = "sumo-dev"
  mysql_instance_class        = "db.t2.small"
  mysql_backup_retention_days = 7
  mysql_security_group_name   = "sumo_rds_sg_dev"
  db_subnet_group_name        = data.terraform_remote_state.vpc.outputs.db_subnet_group
  mysql_storage_gb            = 250
  mysql_storage_type          = "gp2"
  vpc_id                      = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr                    = data.terraform_remote_state.vpc.outputs.cidr_block
  it_vpn_cidr                 = var.it_vpn_cidr
}

/*
module "mysql-stage" {
    source = "./rds"
    mysql_env     = "stage"
    # DBName must begin with a letter and contain only alphanumeric characters
    mysql_db_name = "sumo_stage"
    mysql_username = "root"
    mysql_password = "${var.mysql_stage_password}"
    mysql_identifier = "sumo-stage"
    mysql_instance_class = "db.t2.small"
    mysql_backup_retention_days = 7
    mysql_security_group_name = "sumo_rds_sg_stage"
    mysql_storage_gb = 250
    mysql_storage_type = "gp2"
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
    vpc_cidr                    = "${data.terraform_remote_state.vpc.cidr_block}"
    it_vpn_cidr = "${join(",", var.it_vpn_cidr)}"
}
*/
