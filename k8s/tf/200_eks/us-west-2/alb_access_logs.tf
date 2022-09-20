resource "aws_s3_bucket" "mozit-sumo-alb-access-logs-us-west-2" {
  bucket = "mozit-sumo-alb-access-logs-us-west-2"
}

resource "aws_s3_bucket_acl" "mozit-sumo-alb-access-logs-us-west-2" {
  bucket = aws_s3_bucket.mozit-sumo-alb-access-logs-us-west-2.id
  acl    = "private"
}

data "aws_iam_policy_document" "mozit-sumo-alb-access-logs-us-west-2" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "797873946194",
      ]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.mozit-sumo-alb-access-logs-us-west-2.arn}/prod/AWSLogs/*",
      "${aws_s3_bucket.mozit-sumo-alb-access-logs-us-west-2.arn}/stage/AWSLogs/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "mozit-sumo-alb-access-logs-us-west-2" {
  bucket = aws_s3_bucket.mozit-sumo-alb-access-logs-us-west-2.id
  policy = data.aws_iam_policy_document.mozit-sumo-alb-access-logs-us-west-2.json
}

resource "aws_s3_bucket_lifecycle_configuration" "mozit-sumo-alb-access-logs-us-west-2" {
  bucket = aws_s3_bucket.mozit-sumo-alb-access-logs-us-west-2.id

  rule {
    id     = "expire-logfiles-after-7-days"
    status = "Enabled"

    expiration {
      days                         = 7
      expired_object_delete_marker = false
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}
