output "s3-kops-state-bucket" {
  value = "${aws_s3_bucket.sumo-kops-state.id}"
}
