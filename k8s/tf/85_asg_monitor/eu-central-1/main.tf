provider "aws" {
  region  = "eu-central-1"
  version = "~> 2"
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-infra-sns-asg-eu"
    region = "us-west-2"
  }
}

variable "slack_webhook_url" {}

module "monitor_asgs" {
  source            = "github.com/mozilla-it/asg-alert?ref=1.0"
  slack_webhook_url = "${var.slack_webhook_url}"
  slack_channel     = "it-sre-bot"
  slack_username    = "AWS"

  asgs = [
    "nodes.k8s.eu-central-1a.sumo.mozit.cloud",
    "master-eu-central-1a.masters.k8s.eu-central-1a.sumo.mozit.cloud",
  ]
}
