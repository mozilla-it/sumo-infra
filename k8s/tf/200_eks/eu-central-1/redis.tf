resource "aws_elasticache_replication_group" "prod" {
  replication_group_id          = "sumo-redis-prod-env"
  replication_group_description = "SUMO Redis prod cluster"
  node_type                     = "cache.m5.large"
  number_cache_clusters         = 3
  port                          = 6379
  engine_version                = "5.0.5"
  automatic_failover_enabled    = true
  multi_az_enabled              = true

  subnet_group_name  = "sumo-backup"
  security_group_ids = [data.aws_security_group.sumo-eks-eu-central-1.id]
  tags = {
    "environment" = "prod",
    "application" = "sumo",
    "Terraform"   = "true"
  }
}

resource "aws_elasticache_cluster" "stage" {
  cluster_id        = "sumo-redis-stage-env"
  engine            = "redis"
  node_type         = "cache.t3.micro"
  num_cache_nodes   = 1
  engine_version    = "5.0.5"
  port              = 6379
  subnet_group_name = "sumo-backup"
  security_group_ids = [
    data.aws_security_group.nodes_k8s_eu-central-1a_sumo_mozit_cloud.id,
    data.aws_security_group.sumo-eks-eu-central-1.id
  ]
  tags = {
    "environment" = "stage",
    "application" = "sumo"
  }
}

resource "aws_elasticache_cluster" "dev" {
  cluster_id         = "sumo-redis-dev-env"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  engine_version     = "6.x"
  port               = 6379
  subnet_group_name  = "sumo-backup"
  security_group_ids = [data.aws_security_group.sumo-eks-eu-central-1.id]
  apply_immediately  = true
  tags = {
    "environment" = "dev",
    "application" = "sumo"
  }
}
