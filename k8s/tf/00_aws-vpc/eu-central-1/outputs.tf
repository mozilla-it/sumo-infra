output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "cidr_block" {
  value = "${module.vpc.vpc_cidr_block}"
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}
