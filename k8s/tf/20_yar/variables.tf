variable "region" {
  default = "us-west-2"
}

variable "iam_user" {
  default = "yar-bot-sumo"
}

variable "base_tags" {
  default = {
    "method"      = "terraform"
    "project"     = "sumo"
    "service"     = "sumo-yar"
    "region"      = "us-west-2"
    "environment" = "prod"
    "source"      = "gh:mozilla-it/sumo-infra:mozilla-it/sumo-private"
  }
}

