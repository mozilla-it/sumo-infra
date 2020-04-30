output "subnet_cidr_blocks" {
  value = data.aws_subnet.database
}

output "database_subnet_ids" {
  value = [data.aws_subnet_ids.database.ids]
}

output "kops_security_groups" {
  value = [data.aws_security_groups.kops_sg.ids]
}

