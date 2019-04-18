
output lb_id {
  value = "${aws_lb.balancer.dns_name}"
}

output backup_bucket_name {
  value = "${aws_s3_bucket.backup.id}"
}
