resource "aws_s3_bucket" "sumo-static-media" {
  bucket = var.bucket_name
  acl    = "log-delivery-write"

  force_destroy = false

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  hosted_zone_id = var.hosted-zone-id-defs[var.region]

  logging {
    target_bucket = var.logging_bucket_id
    target_prefix = var.logging_prefix
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  website_domain   = "s3-website-${var.region}.amazonaws.com"
  website_endpoint = "${var.bucket_name}.s3-website-${var.region}.amazonaws.com"

  versioning {
    enabled = true
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "${var.bucket_name} policy",
  "Statement": [
    {
      "Sid": "${var.iam_policy_name}AllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.bucket_name}"
    },
    {
      "Sid": "${var.iam_policy_name}AllowIndexDotHTML",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*"
    }
  ]
}
EOF

}
