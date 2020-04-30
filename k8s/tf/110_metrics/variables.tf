variable "metrics_user" {
  default     = "arn:aws:iam::177680776199:root"
  description = "ARN of the user/account fetching ELB metrics. Defaults to mozilla-itsre account"
}

variable "region" {
  default = "us-west-2"
}

