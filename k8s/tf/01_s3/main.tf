resource "aws_s3_bucket" "sumo-kops-state" {
  bucket = "${var.s3_kops_state}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = "${var.base_tags}"
}
