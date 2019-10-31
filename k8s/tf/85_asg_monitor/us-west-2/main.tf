provider "aws" {
  region  = "us-west-2"
  version = "~> 2"
}

terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-infra-sns-asg"
    region = "us-west-2"
  }
}

variable "slack_webhook_url" {}

module "monitor_asgs" {
  source            = "github.com/mozilla-it/asg-alert?ref=tags/1.0"
  slack_webhook_url = "${var.slack_webhook_url}"
  slack_channel     = "it-sre-bot"
  slack_username    = "AWS"

  asgs = [
    "nodes.k8s.us-west-2a.sumo.mozit.cloud",
    "master-us-west-2a.masters.k8s.us-west-2a.sumo.mozit.cloud",
    "nodes.k8s.us-west-2b.sumo.mozit.cloud",
    "master-us-west-2b.masters.k8s.us-west-2b.sumo.mozit.cloud",
  ]
}
