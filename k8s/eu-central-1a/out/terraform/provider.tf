terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/kops-eu-central-1a"
    region = "us-west-2"
  }
}
