resource "aws_elasticache_cluster" "dev" {
  cluster_id         = "sumo-redis-dev-env"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  engine_version     = "5.0.5"
  port               = 6379
  subnet_group_name  = "sumo-backup"
  security_group_ids = [data.aws_security_group.nodes_k8s_eu-central-1a_sumo_mozit_cloud.id]
  tags = {
    "environment" = "dev",
    "application" = "sumo"
  }
}

resource "aws_elasticache_cluster" "test" {
  cluster_id         = "sumo-redis-test-env"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  engine_version     = "5.0.5"
  port               = 6379
  subnet_group_name  = "sumo-backup"
  security_group_ids = [data.aws_security_group.nodes_k8s_eu-central-1a_sumo_mozit_cloud.id]
  tags = {
    "environment" = "test",
    "application" = "sumo"
  }
}
