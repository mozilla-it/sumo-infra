resource "aws_elasticache_cluster" "stage" {
  cluster_id         = "sumo-redis-stage-env"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  engine_version     = "5.0.5"
  port               = 6379
  subnet_group_name  = "sumo-prod"
  security_group_ids = [
    data.aws_security_group.nodes_k8s_us-west-2b_sumo_mozit_cloud.id,
    data.aws_security_group.nodes_k8s_us-west-2a_sumo_mozit_cloud.id,
    data.aws_security_group.sumo-eks-us-west-2.id
  ]
  tags = {
    "environment" = "stage",
    "application" = "sumo"
  }
}
