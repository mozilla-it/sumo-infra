variable "region" {
  default = "us-west-2"
}

variable "mdc_cidr" {
  default = "10.48.0.0/15"
}

variable "acm_cert" {
  default = "*.sumo.mozit.cloud"
}

variable "route53_zone" {
  default = "ZXCBUDNBNSCXV"
}

variable "instance_type" {
  default = "m5.xlarge"
}

variable "project" {
  default = "sumo"
}

variable "service" {
  default = "ci"
}

variable "domain" {
  default = "sumo.mozit.cloud"
}

variable "ssh_pubkey" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCWRvKjg4pkZgCgGiuxhMxHq8mj2NMEPfjY0nzITbITo8fTkFTWNcy3LgineWSriq/MPWnRAcZ89kqE/8fno9k6016GSx/1F8cWXTLTL0wMSXj/YNyXhe4QhEvUdnm0l3gVZpUWwH2TmE0aJYp9QJrEjurDK5/JP6zyBPG6/+b+xsMANtli4C7RnxjCQQPGQelngKcGGTQM3CmVYq/CQT01DQpbv9WgqVKT+JAvAOn88QNenyrqXDRCw9gHk+YDVcBO9y8/QBjF5jLNkGPm7ia6KAl+skOj+NgcMCIZKg8KfmKo32Kpng5YSaUdy6VGkEkU82mZkk8w4I1uDYycQj88jsHmgeBVLU7WKZOd7d04Mpri+0YYwLq8MPU+wDPjOEzpG7ni4KLTkjpDIySzhbVBF3BsRjugzHEBmF7eWYXCwCmYTAvIIdmEiCLsJRzeSsCwn1AR64y2AnFXmnyypSRhRcYwGGqlg4zhuDxMMWp4IPyjbzNzRvWS1oMzVSUeeb7bUg6bC/hv6KySJHvHazaijUZgbpjIc5pAorgb25abM0hRbaDWUD2Du79GQsHUy3VjIchbfgU/9p3x/vsmFp1ugBDHUNkoLT4dyJD9lBcOUUzwtNHWZEA7ijqvQhKQfvrp133s67op+12vK+JN10kGvtNcKokaANY7hrTM/rqzGQ== sumo-kops"
}

variable "backup_bucket" {
  default = "ci-backup"
}

variable "backup_dir" {
  default = "/data/backups"
}

# Tags to apply across the VPC resources
variable "base_tags" {
  default = {
    "method"      = "terraform"
    "project"     = "sumo"
    "service"     = "sumo-ci"
    "region"      = "us-west-2"
    "environment" = "prod"
    "source"      = "gh:mozilla-it/sumo-infra:mozilla-it/ansible-jenkins"
  }
}

variable "parameter_root_name" {
  default = "/sumo-ci/ssh/l10n-deploy"
}

variable "static_s3_prefix" {
  default = "mozit-sumo*-media*"
}

variable "nginx_htpasswd" {}

variable "jenkins_backup_dms" {}

variable "papertrail_host" {}

variable "papertrail_port" {}

variable "slack_token" {}

variable "gh_deploy_key" {}
