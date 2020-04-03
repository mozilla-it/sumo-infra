output "delegation_sets" {
  value = join(",", aws_route53_delegation_set.delegation-set.name_servers)
}

output "delegation_set_id" {
  value = aws_route53_delegation_set.delegation-set.id
}

output "master-zone" {
  value = element(concat(aws_route53_zone.master-zone.*.zone_id, [""]), 0)
}

output "us-west-2-zone-id" {
  value = module.us-west-2.hosted_zone_id
}

output "us-west-2a-zone-id" {
  value = module.us-west-2a.hosted_zone_id
}

output "us-west-2b-zone-id" {
  value = module.us-west-2b.hosted_zone_id
}

output "cdn-zone-id" {
  value = aws_route53_zone.cdn.zone_id
}

