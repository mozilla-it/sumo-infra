output "delegation_sets" {
  value = join(",", aws_route53_delegation_set.delegation-set.name_servers)
}

output "delegation_set_id" {
  value = aws_route53_delegation_set.delegation-set.id
}

output "master-zone" {
  value = element(concat(aws_route53_zone.master-zone.*.zone_id, [""]), 0)
}

output "cdn-zone-id" {
  value = aws_route53_zone.cdn.zone_id
}

