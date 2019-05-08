resource "aws_elasticache_replication_group" "sumo-redis-rg" {
  replication_group_id          = "sumo-redis-${var.redis_name}"
  replication_group_description = "SUMO Redis ${var.redis_name} cluster"
  node_type                     = "${var.redis_node_size}"
  number_cache_clusters         = "${var.redis_num_nodes}"
  port                          = "${var.redis_port}"
  parameter_group_name          = "${var.redis_param_group}"
  engine_version                = "${var.redis_engine_version}"

  subnet_group_name  = "${var.redis_subnet}"
  security_group_ids = ["${split(",", var.nodes_security_groups)}"]

  tags {
    Stack = "SUMO-${var.redis_name}"
  }
}
