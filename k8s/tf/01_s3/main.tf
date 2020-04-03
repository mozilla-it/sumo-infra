resource "aws_s3_bucket" "sumo-kops-state" {
  bucket = var.s3_kops_state
#  acl    = "private"

  versioning {
    enabled = true
  }

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  grant {
    type        = "Group"
    permissions = ["READ_ACP", "WRITE"]
    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  }

  tags = var.base_tags
}

