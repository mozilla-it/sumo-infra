output "ark_bucket" {
  value = "${module.ark_bucket.bucket_name}"
}

output "ark_access_key" {
  value = "${module.ark_bucket.backup_user_access_key}"
}

output "ark_secret_key" {
  value = "${module.ark_bucket.backup_user_secret_key}"
}
