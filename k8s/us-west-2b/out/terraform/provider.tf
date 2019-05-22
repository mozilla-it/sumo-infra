terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/kops-us-west-2b"
    region = "us-west-2"
  }
}
