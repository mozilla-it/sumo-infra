output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "db_subnet_group" {
  value = module.vpc.database_subnet_group
}

output "redis_subnet_group" {
  value = module.vpc.elasticache_subnet_group
}

